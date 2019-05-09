
webview_app: ext_package
	cd webview && go build

ext_package:
	go get github.com/zserge/webview
	touch ext_package
  
install:
	mv webview/webview ./webview_app

clean:
	rm webview_app
	rm ext_package
