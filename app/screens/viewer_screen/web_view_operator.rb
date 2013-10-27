class ViewerScreen < PM::WebScreen
  module WebViewOperator
    def go_back
      if webview.canGoBack
        PM.logger.debug "go back"
        webview.goBack
      end
    end

    def go_forward
      if webview.canGoForward
        PM.logger.debug "go forward"
        webview.goForward
      end
    end

    def reload
      PM.logger.debug "reload"
      webview.reload
    end

    def on_load_started
      go_forward_button.enabled = webview.canGoForward ? true : false
      go_back_button.enabled = webview.canGoBack ? true : false
    end

    def on_load_finished
      webview.keyboardDisplayRequiresUserAction = true
    end
  end
end
