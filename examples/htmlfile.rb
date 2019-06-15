$LOAD_PATH << File.expand_path('../../lib', __FILE__)

require 'webview'

app = Webview::App.new(title: 'Ruby Language')
filepath = File.expand_path('../rpc.html', __FILE__)
app.open("file://#{filepath}")

at_exit { app.close }
begin
  app.join
rescue Interrupt
  app.close
end

