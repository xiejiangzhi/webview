require 'timeout'
require 'shellwords'
require 'open3'

module Webview
  class App
    attr_reader :app_out, :app_err, :app_process

    def initialize(debug: false)
      @debug = debug
    end

    def open(url)
      return true if @app_process
      cmd = [
        File.expand_path('ext/webview_app', ROOT_PATH),
        '-url', Shellwords.escape(url)
      ]
      cmd << '-debug' if @debug
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
