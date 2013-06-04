module WebViewBase

  def self.included(base)
    base.extend(ClassMethods)
  end

  def open_webview(url)
    self.view = UIWebView.alloc.init
    ns_url = NSURL.URLWithString(url)

    request = NSURLRequest.requestWithURL(ns_url)
    self.view.loadRequest request
  end

  module ClassMethods
    def set_base_url(base_url)
      @base_url = base_url
    end

    def base_url
      @base_url
    end
  end

end
