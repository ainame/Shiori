# -*- coding: utf-8 -*-
class ViewerScreen < PM::Screen
  include WebScreenModule

  self.debug_web_bridge  = true
  self.bridge_url_scheme = 'shiori-webview'
  STARS_URL = 'https://github.com/stars'
  TEST_URL = 'https://github.com/ainame/motion-mode/blob/master/motion-mode.el'

  title 'Github viewer'

  def to_load_url
    App::Persistence['last_url'] ? App::Persistence['last_url'] : STARS_URL
  end

  def on_load
    toggle_star_button
    set_tool_bar
    open_url to_load_url
  end

  def web_view_before_load(web_view, request, navigation_type)
    App.shared.networkActivityIndicatorVisible = true;
  end

  def web_view_finish_load(web_view)
    App.shared.networkActivityIndicatorVisible = false;
    self.title = get_repository_name
    App::Persistence['last_url'] = current_url
    inject_js
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
  var repo_attributes = $("[itemprop=title]");
  var author = repo_attributes[0].innerText;
  var repository_name = repo_attributes[1].innerText;
  var file_name_with_repo_name = $(".breadcrumb").text().trim().replace(/ /g, "");
  var file_name = purge_repository_name(file_name_with_repo_name);
  var json = {
      line: line,
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

  def register_star
    idx = is_starred ? 0 : 1
    script = <<"JS"
$($(".star-button")[#{idx}]).trigger("click");
JS
    eval_js_src(script)
    toggle_star_button
  end

  def is_starred
    script = <<JS
$($(".star-button")[0]).parent().hasClass("on");
JS
    result = eval_js_src(script)
    result == 'true' ? true : false
  end

  def initialize_star_button
    @star_button_flag = !is_starred
    toggle_star_button
  end

  def toggle_star_button
    @star_button_flag = !@star_button_flag

    button = UIButton.buttonWithType(UIButtonTypeCustom).tap do |b|
      image = UIImage.imageNamed(@star_button_flag ? "standard/star" : "standard/alarm")
      image.userInteractionEnabled = true
      b.setImage(image, forState: UIControlStateNormal)
      b.frame = CGRectMake(0,0,25,25)
    end
    self.navigationItem.rightBarButtonItem =
      UIBarButtonItem.alloc.initWithCustomView(button)
  end

end
