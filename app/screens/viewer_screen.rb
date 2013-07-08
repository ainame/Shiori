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
  end

  def load_finished
    App.shared.networkActivityIndicatorVisible = false;
    App::Persistence['last_url'] = current_url
    self.title = get_repository_name
    inject_rpc_js
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

  def inject_rpc_js
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
    evaluate(script)
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
    evaluate(script)
  end

  def execute_finder
    # emurate "t"'s shortcut
    self.webview.keyboardDisplayRequiresUserAction = false
    script = <<JS
(function(){
  var event = $.Event("keydown");
  event.hotkey = "t";
  event.target = document.body;
  $(document.body).trigger(event);    
  $("input[name=query]")[0].focus();
})();
JS
    evaluate(script)
  end

  def get_user_link
    script = <<JS
(function(){
  return $("#user-links").find("a").attr("href");
})();
JS
    evaluate(script)
  end
end
