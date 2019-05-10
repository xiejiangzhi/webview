
webview_app: ext_package
	cd webview && go build

ext_package:
	go get github.com/zserge/webview
	touch ext_package
  
install:
	mv webview/webview ./webview_app

clean:
	rm -f webview_app
	rm -f ext_package
