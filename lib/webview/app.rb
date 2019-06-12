require 'timeout'
require 'open3'

module Webview
  class App
    attr_reader :app_out, :app_err, :app_process, :options

    SIGNALS_MAPPING = case Gem::Platform.local.os
    when 'mingw32'
      {
        'QUIT' => 'EXIT',
      }
    else
      {} # don't map
    end

    def initialize(title: nil, width: nil, height: nil, resizable: nil, debug: false)
      @options = {
        title: title,
        width: width,
        height: height,
        resizable: resizable,
        debug: debug
      }
      @options.delete_if { |k, v| v.nil? }
      @app_out = nil
      @app_err = nil
      @app_process = nil
    end

    def open(url)
      return true if @app_process
      cmd = [executable, "-url \"#{url}\""]
      @options.each do |k, v|
        case v
        when true, false then cmd << "-#{k}" if v
        else cmd << "-#{k} \"#{v}\""
        end
      end
      exec_cmd(cmd.join(' '))
    end

    def close
      return true unless app_process
      app_out.close
      app_err.close

      pid = app_process.pid
      signal('QUIT')
      begin
        Timeout.timeout(3) do
          Process.wait(pid)
        rescue Errno::ECHILD, Errno::ESRCH
        end
      rescue Timeout::Error
        kill
      end

      @app_process = nil
    end

    def join
      return unless app_process && app_process.alive?
      Process.wait(app_process.pid)
    rescue Errno::ECHILD, Errno::ESRCH
    end

    def kill
      signal('KILL')
    end

    def signal(name)
      return false unless app_process&.pid
      s = SIGNALS_MAPPING[name] || name
      Process.kill(Signal.list[s], app_process.pid)
      true
    rescue Errno::ECHILD, Errno::ESRCH
      false
    end

    private

    def executable
      File.expand_path('ext/webview_app', ROOT_PATH)
    end

    def exec_cmd(cmd)
      app_in, @app_out, @app_err, @app_process = Open3.popen3(cmd)
      app_in.close
      if app_process && app_process.alive?
        true
      else
        false
      end
    end
  end
end
