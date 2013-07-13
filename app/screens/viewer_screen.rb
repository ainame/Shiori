# -*- coding: utf-8 -*-
class ViewerScreen < PM::WebScreen
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
  self.debug_web_bridge  = true
  self.bridge_url_scheme = 'shiori-webview'
  STARS_URL = 'https://github.com/stars'

  title 'Github viewer'

  def content
    to_load_url
  end

  def to_load_url
    url = App::Persistence['last_url'] ? App::Persistence['last_url'] : STARS_URL
    NSURL.URLWithString(url)
  end

  def on_load
    init_star_button
    set_tool_bar
    load_js_src
  end

  def load_finished
    App.shared.networkActivityIndicatorVisible = false;
    App::Persistence['last_url'] = current_url
    inject_js_src
    self.title = get_repository_name
    reset_star_button
    set_user_link_url_to_master
    self.webview.keyboardDisplayRequiresUserAction = true
  end

  def on_request(request, navigation_type)
    url = request.URL
    return true unless url.scheme == self.class.bridge_url_scheme

    PM.logger.log("DEBUG", "passed URL - #{url.scheme}://#{url.host} from WebView", :blue) if self.class.debug_web_bridge
    method, message = request.URL.host.match(/(.*)(\{.*\})/).captures
    params = BW::JSON.parse(message)
    dispatch_rpc(method, params)
    false
  end

  def dispatch_rpc(method, params)
    case method
    when 'clickLineOfCode'
      bm = BookMark.new(params)
      bm.save
    end
  end

  def set_tool_bar
    sc = UIScreen.mainScreen
    @tool_bar =  UIToolbar.alloc.initWithFrame(
      CGRectMake(0, sc.applicationFrame.size.height - 44,
        sc.applicationFrame.size.width, 44)
    )
    left_arrow = UIImage.imageNamed("iconbeast/arrow-big-01")
    right_arrow = UIImage.imageNamed("iconbeast/arrow-big-02")

    button_list = []
    button_list << UIBarButtonItem.alloc.initWithBarButtonSystemItem(
      UIBarButtonSystemItemSearch, target: self, action: :execute_finder)
    button_list << UIBarButtonItem.alloc.initWithBarButtonSystemItem(
      UIBarButtonSystemItemFlexibleSpace, target: self, action: nil)
    button_list << UIBarButtonItem.alloc.initWithImage(left_arrow,
      style: UIBarButtonItemStylePlain, target: self.webview, action: :goBack)
    button_list << UIBarButtonItem.alloc.initWithImage(right_arrow,
      style: UIBarButtonItemStylePlain, target: self.webview, action: :goForward)
    button_list << UIBarButtonItem.alloc.initWithBarButtonSystemItem(
      UIBarButtonSystemItemRefresh, target: self.webview, action: :reload)
    self.view.addSubview(@tool_bar)
    self.navigationController.toolbarHidden = false
    self.setToolbarItems(button_list, animated: true)
  end

  def init_star_button
    @star_button = StarButtonView.new(self)
    if button = @star_button.create_button
      set_nav_bar_button :right, button: button
    end
  end

  def reset_star_button
    @star_button.set_current_star_state
    if button = @star_button.create_button
      set_nav_bar_button :right, button: button
    end
  end

  def popup_book_mark
    app_delegate.popover_screen.presentPopoverFromBarButtonItem(
      app_delegate.book_mark_button,
      permittedArrowDirections: UIPopoverArrowDirectionDown,
      animated: true)
  end

  def set_user_link_url_to_master
    user_link_url = "https://github.com#{get_user_link}"
    self.splitViewController.master_screen.user_link_url =
      user_link_url
  end

  def load_js_src
    path = File.join(App.resources_path, 'application.js')
    @js_src = NSString.stringWithContentsOfFile(path, encoding: NSUTF8StringEncoding, error: nil)
  end

  def inject_js_src
    evaluate(@js_src)
    evaluate("Shiori.attachClickLineOfCodeEvent();")
  end

  def get_repository_name
    evaluate("Shiori.getRepositoryName();")
  end

  def execute_finder
    # emurate "t"'s shortcut
    self.webview.keyboardDisplayRequiresUserAction = false
    evaluate("Shiori.executeFinder();")
  end

  def get_user_link
    evaluate("Shiori.getUserLinks();")
  end
end
