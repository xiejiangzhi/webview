$LOAD_PATH << File.expand_path('../../lib', __FILE__)

require 'webview'

app = Webview::App.new(title: 'Ruby Language')
app.open('https://www.ruby-lang.org?foo=bar')

at_exit { app.close }
begin
  app.join
rescue Interrupt
  app.close
end

