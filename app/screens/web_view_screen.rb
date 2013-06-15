module ProMotion
  class WebViewScreen < ViewController

    class << self
      def debug_web_bridge=(bool = false)
        @debug_web_bridge = !!bool
      end

      def debug_web_bridge
        @debug_web_bridge
      end

      def bridge_url_scheme=(url)
        @bridge_url_scheme = url
      end

      def bridge_url_scheme
        @bridge_url_scheme
      end
    end

    def open_url(url)
      unless self.view.kind_of?(UIWebView)
        self.view = UIWebView.new
        self.view.delegate = self
      end

      ns_url = NSURL.URLWithString(url)
      request = NSURLRequest.requestWithURL(ns_url)
      self.view.loadRequest(request)
    end

    def eval_js_src(js_src)
      self.view.stringByEvaluatingJavaScriptFromString(js_src)
    end

    def on_rpc_call(url)
      raise 'override me'
    end

    def current_url
      eval_js_src('document.URL')
    end

    def webViewDidStartLoad(webView)
      web_view_start_load(webView) if self.respond_to?(:web_view_start_load)
    end

    def webViewDidFinishLoad(webView)
      web_view_finish_load(webView) if self.respond_to?(:web_view_finish_load)
    end

    def webView(webView, shouldStartLoadWithRequest:request, navigationType:navigationType)
      url = request.URL
      PM.logger.log("DEBUG", "#{url.scheme}://#{url.host}", :purple)
      if url.scheme == self.class.bridge_url_scheme
        PM.logger.log("DEBUG", "passed URL - #{url.scheme}://#{url.host} from WebView", :blue) if self.class.debug_web_bridge
        on_rpc_call(url)
        return false
      end

      web_view_before_load(webView, request, navigationType) if self.respond_to?(:before_load)
      true
    end

  end
end
