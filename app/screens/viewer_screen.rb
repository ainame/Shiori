# -*- coding: utf-8 -*-
class ViewerScreen < PM::WebScreen
  include TogglePanelButton
  include WebViewOperateHelper
  include WebBridgeHelper

  STARS_URL = 'https://github.com/stars'

  title 'Github viewer'
  attr_reader :go_back_button, :go_forward_button

  # for io7 http://qiita.com/kouchi67/items/cfd39c8c0b97baeb8f48
  def view_did_load
    if UIDevice.currentDevice.ios7?
      self.edgesForExtendedLayout = UIRectEdgeNone
      self.extendedLayoutIncludesOpaqueBars = false
      self.automaticallyAdjustsScrollViewInsets = false
    end
  end

  def content
    to_load_url
  end

  def to_load_url
    url = App::Persistence['last_url'] ? App::Persistence['last_url'] : STARS_URL
    NSURL.URLWithString(url)
  end

  def on_load
    set_tool_bar
    set_toggle_panel_button
    load_js_src
  end

  def load_started
    inject_js_src
    on_load_started
  end

  def load_finished
    inject_js_src
    set_star_button
    reset_star_button
    set_user_link_url_to_master
    set_title
    on_load_finished
  end

  def on_request(request, navigation_type)
    dispatcher = WebBridgeRequestDispatcher.new(request)
    unless dispatcher.web_bridge_request?
      App::Persistence['last_url'] = dispatcher.url.absoluteString
      return true
    end

    dispatcher.execute
    return false
  end

  def set_tool_bar
    sc = UIScreen.mainScreen
    @tool_bar =  UIToolbar.alloc.initWithFrame(
      CGRectMake(0, sc.applicationFrame.size.height - 44,
        sc.applicationFrame.size.width, 44)
    )
    @go_back_button = UIBarButtonItem.alloc.initWithImage(
      UIImage.imageNamed("back-25"), style: UIBarButtonItemStylePlain, target: self, action: :go_back
    )
    @go_forward_button = UIBarButtonItem.alloc.initWithImage(
      UIImage.imageNamed("forward-25"), style: UIBarButtonItemStylePlain, target: self, action: :go_forward
    )

    button_list = []
    button_list << UIBarButtonItem.alloc.initWithBarButtonSystemItem(
      UIBarButtonSystemItemSearch, target: self, action: :execute_finder)
    button_list << UIBarButtonItem.alloc.initWithBarButtonSystemItem(
      UIBarButtonSystemItemAction, target: self, action: :execute_ui_activity)
    button_list << UIBarButtonItem.alloc.initWithBarButtonSystemItem(
      UIBarButtonSystemItemFlexibleSpace, target: self, action: nil)
    button_list << @go_back_button
    button_list << @go_forward_button
    button_list << UIBarButtonItem.alloc.initWithBarButtonSystemItem(
      UIBarButtonSystemItemRefresh, target: self, action: :reload)
    self.view.addSubview(@tool_bar)
    self.navigationController.toolbarHidden = false
    self.setToolbarItems(button_list, animated: true)
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

  def set_title
    self.title = get_repository_name
  end

  def execute_ui_activity
    format = "%s を読んでます！%s #github_shiori"
    url   = NSURL.URLWithString(current_url)
    text = format % [get_repository_name, current_url]
    activityItems = [text, url]

    if UIActivityViewController.class
      activityView = UIActivityViewController.alloc.initWithActivityItems(
        activityItems, applicationActivities: [HTBHatenaBookmarkActivity.new]
      )
      self.presentViewController(activityView, animated: true, completion:nil)
    end
  end

end
