# -*- coding: utf-8 -*-
class ViewerScreen < PM::Screen
  include WebScreenModule

  self.debug_web_bridge  = true
  self.bridge_url_scheme = 'shiori-webview'
  TEST_URL = 'https://github.com/ainame/motion-mode/blob/master/motion-mode.el'

  def on_load
    open_url TEST_URL
  end

  def web_view_before_load(web_view, request, navigation_type)
    App.shared.networkActivityIndicatorVisible = true;
  end

  def web_view_finish_load(web_view)
    App.shared.networkActivityIndicatorVisible = false;
    @last_url = current_url
    inject_js
  end

  def on_rpc_call(url)
    method, message = url.host.match(/(.*)(\{.*\})/).captures
    params = BW::JSON.parse(message)
    case method
    when 'clickLineOfCode'
      p params
      bm = BookMark.new(params)
      bm.save
    end
  end

  def on_return(params = {})
    open_url params[:url] if params[:url]
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

end
