# -*- coding: utf-8 -*-
class GithubScreen < PM::WebViewScreen
  include SingletonClass
  self.debug_web_bridge  = true
  self.bridge_url_scheme = 'shiori-webview'

  def on_load
    open_url 'https://github.com'
  end

  def finish_load(web_view)
    @last_url = current_url
    inject_js
  end

  def on_rpc_call(url)
    case url.host
    when 'clickLineOfCode'
      App.alert("Hello Motion!", cancel_button_title: 'cancel')
    end
  end

  def inject_js
    script = <<JS
function callRPCRequest(url){
  console.log(url);
  location.href = url;
}

$(document).on("mousedown", ".line-number, .blob-line-nums span[rel]", function(){
  callRPCRequest("shiori-webview://clickLineOfCode");
});
JS
    eval_js_src(script)
  end

end
