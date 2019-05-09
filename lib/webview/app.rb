require 'timeout'
require 'open3'

module Webview
  class App
    attr_reader :app_out, :app_err, :app_process, :options

    def initialize(title: nil, width: nil, height: nil, resizable: nil, debug: false)
      @options = {
        title: title,
        width: width,
        height: height,
        resizable: resizable,
        debug: debug
      }
      @options.delete_if { |k, v| v.nil? }
    end

    def open(url)
      return true if @app_process
      cmd = [
        File.expand_path('ext/webview_app', ROOT_PATH),
        "-url '#{url}'"
      ]
      @options.each do |k, v|
        case v
        when true, false then cmd << "-#{k}" if v
        else cmd << "-#{k} '#{v}'"
        end
      end
      exec_cmd(cmd.join(' '))
    end

    def close
      return true unless app_process
      app_out.close
      app_err.close

      pid = app_process.pid
      Process.kill('QUIT', pid)
      begin
        Timeout.timeout(3) { Process.wait(pid) }
      rescue Timeout::Error
        kill
      rescue Errno::ECHILD
      end

      @app_process = nil
    end

    def join
      return unless app_process && app_process.alive?
      Process.wait(app_process.pid)
    rescue Errno::ECHILD
    end

    def kill
      return unless app_process&.pid
      Process.kill('TERM', app_process.pid)
    end

    private

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
