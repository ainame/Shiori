# -*- coding: utf-8 -*-
class ViewerScreen < PM::WebScreen
  BRIDGE_URL_SCHEME = 'shiori-webview'
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
    set_tool_bar
    set_bookmark_button
    load_js_src
  end

  def start_indicator
    App.shared.networkActivityIndicatorVisible = true
    @indicator = LoadingIndicatorScreen.new(self)
    @indicator.start
  end

  def stop_indicator
    App.shared.networkActivityIndicatorVisible = false
    @indicator.stop if @indicator
  end

  def load_started
    inject_js_src
  end

  def load_finished
    inject_js_src
    set_star_button
    stop_indicator
    self.title = get_repository_name
    reset_star_button
    set_user_link_url_to_master
    self.webview.keyboardDisplayRequiresUserAction = true
  end

  def id_anchor?(from, to)
    from_url = NSURL.URLWithString(from)
    to_url = NSURL.URLWithString(to)
    from_url.scheme == to_url.scheme && from_url.path == to_url.path
  end

  def on_request(request, navigation_type)
    url = request.URL
    unless url.scheme == BRIDGE_URL_SCHEME
      #start_indicator unless id_anchor?(App::Persistence['last_url'], url.absoluteString)
      App::Persistence['last_url'] = url.absoluteString
      return true 
    end

    PM.logger.log("DEBUG", "passed URL - #{url.scheme}://#{url.host} from WebView", :blue) if RUBYMOTION_ENV == "development"
    method, message = request.URL.host.match(/(.*?)(\{.*\})/).captures
    params = BW::JSON.parse(message)
    dispatch_rpc(method, params)
    #stop_indicator
    return false
  end

  def dispatch_rpc(method, params)
    case method
    when 'clickLineOfCode'
      BookMark.new(params).save
      app_delegate.book_mark.update_table_data
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
      UIBarButtonSystemItemAction, target: self, action: :execute_ui_activity)
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

  def toggle_left_panel
    app_delegate.panels.toggleLeftPanel(nil)
  end

  def set_bookmark_button
    custom_view = UIButton.buttonWithType(UIButtonTypeCustom).tap do |b|
      b.setImage(UIImage.imageNamed("iconbeast/bookmark"), forState: UIControlStateNormal)
      b.frame = CGRectMake(0,0,25,25)
      b.addTarget(self, action: :toggle_left_panel, forControlEvents: UIControlEventTouchUpInside)
    end
    button = UIBarButtonItem.alloc.initWithCustomView(custom_view)
    self.navigationItem.leftBarButtonItem = button
  end

  def set_star_button
    self.evaluate('')
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

  def set_user_link_url_to_master
    user_link_url = "https://github.com#{get_user_link}"
    app_delegate.panels.leftPanel.user_link_url = user_link_url
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
    self.webview.keyboardDisplayRequiresUserAction = true
  end

  def execute_ui_activity
    format = "%s を読んでます！%s #github_shiori"
    url   = NSURL.URLWithString(current_url)
    text = format % [get_repository_name, current_url]
    activityItems = [text]
    activityView = UIActivityViewController.alloc.initWithActivityItems(activityItems, applicationActivities: [])
    self.presentViewController(activityView, animated: true, completion:nil)
  end

  def get_user_link
    evaluate("Shiori.getUserLinks();")
  end
end
