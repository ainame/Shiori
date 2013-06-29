# -*- coding: utf-8 -*-
class ViewerScreen < PM::Screen
  include WebScreenModule

  self.debug_web_bridge  = true
  self.bridge_url_scheme = 'shiori-webview'
  STARS_URL = 'https://github.com/stars'

  title 'Github viewer'

  def to_load_url
    App::Persistence['last_url'] ? App::Persistence['last_url'] : STARS_URL
  end

  def on_load
    init_web_view
    init_star_button
    set_tool_bar
    open_url to_load_url
  end

  def web_view_before_load(web_view, request, navigation_type)
    App.shared.networkActivityIndicatorVisible = true;
  end

  def web_view_finish_load(web_view)
    App.shared.networkActivityIndicatorVisible = false;
    App::Persistence['last_url'] = current_url
    self.title = get_repository_name
    inject_js
    reset_star_button
    set_user_link_url_to_master
    self.web_view.keyboardDisplayRequiresUserAction = true
  end

  def on_rpc_call(url)
    method, message = url.host.match(/(.*)(\{.*\})/).captures
    params = BW::JSON.parse(message)
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
      style: UIBarButtonItemStylePlain, target: self.web_view, action: :goBack)
    button_list << UIBarButtonItem.alloc.initWithImage(right_arrow,
      style: UIBarButtonItemStylePlain, target: self.web_view, action: :goForward)
    button_list << UIBarButtonItem.alloc.initWithBarButtonSystemItem(
      UIBarButtonSystemItemRefresh, target: self.web_view, action: :reload)
    self.view.addSubview(@tool_bar)
    self.navigationController.toolbarHidden = false
    self.setToolbarItems(button_list, animated: true)
  end

  def inject_js
    script = <<JS
function callRPCRequest(url){
  console.log(url)
  location.href = url;
}

function purge_repository_name (string){
  for (var i = 0; i < string.length; i++) {
    if (string[i] === "/"){
      break;
    }
  }
  return string.slice(i+1, string.length);
}

$(document).on("mousedown", ".line-number, .blob-line-nums span[rel]", function(e){
  var line = e.currentTarget.innerText;
  var line_of_code = $("#LC" + line).text().trim();
  var repo_attributes = $("[itemprop=title]");
  var author = repo_attributes[0].innerText;
  var repository_name = repo_attributes[1].innerText;
  var file_name_with_repo_name = $(".breadcrumb").text().trim().replace(/ /g, "");
  var file_name = purge_repository_name(file_name_with_repo_name);
  var json = {
    line: line,
    line_of_code: line_of_code,
    file_name: file_name,
    author: author,
    repository_name: repository_name,
    url: document.URL
  };
  var encodedParams = encodeURIComponent(JSON.stringify(json));
  var message = "shiori-webview://clickLineOfCode" + encodedParams;
  callRPCRequest(message);
});
JS
    eval_js_src(script)
  end

  def get_repository_name
    script = <<JS
(function(){
  var repo_attributes = $("[itemprop=title]");
  var author = repo_attributes[0].innerText;
  var repository_name = repo_attributes[1].innerText;
  return author + "/" + repository_name;
})();
JS
    eval_js_src(script)
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

  def execute_finder
    # emurate "t"'s shortcut
    self.web_view.keyboardDisplayRequiresUserAction = false
    script = <<JS
(function(){
  var event = $.Event("keydown");
  event.hotkey = "t";
  event.target = document.body;
  $(document.body).trigger(event);    
  $("input[name=query]")[0].focus();
})();
JS
    eval_js_src(script)
  end

  def get_user_link
    script = <<JS
(function(){
  return $("#user-links").find("a").attr("href");
})();
JS
    eval_js_src(script)
  end

  def set_user_link_url_to_master
    user_link_url = "https://github.com#{get_user_link}"
    self.splitViewController.master_screen.user_link_url =
      user_link_url
  end

end
