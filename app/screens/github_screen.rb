class GithubScreen < PM::Screen
  include WebViewBase

  def on_load
    open_webview 'http://github.com' 
  end

end
