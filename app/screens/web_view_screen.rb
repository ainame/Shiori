module ProMotion
  class WebViewScreen < UIViewController

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
        self.view = UIWebView.alloc.init 
        self.view.delegate = self
      end

      ns_url = NSURL.URLWithString(url)
      request = NSURLRequest.requestWithURL(ns_url)
      self.view.loadRequest request
    end

    def load_js_src(js_src)
      self.view.stringByEvaluatingJavaScriptFromString(js_src)
    end

    def on_rpc_call(url)
      raise 'override me'
    end

    def on_load_web_view(webView)
      raise 'override me'
    end

    def webViewDidFinishLoad(webView)
      on_load_web_view(webView)
    end

    def webView(webView, shouldStartLoadWithRequest:request, navigationType:navigationType)
      return if self.class.bridge_url_scheme.nil?
      url = request.URL

      if url.scheme == self.class.bridge_url_scheme
        puts "DEBUG: passed URL - #{url.scheme}://#{url.host} from WebView" if self.class.debug_web_bridge
        on_rpc_call(url)
        return false
      end

      true
    end

  end
end
