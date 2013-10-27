class ViewerScreen < PM::WebScreen
  module WebBridgeHelper
    def get_user_link
      evaluate("Shiori.getUserLinks();")
    end

    def execute_finder
      # emurate "t"'s shortcut
      self.webview.keyboardDisplayRequiresUserAction = false
      evaluate("Shiori.executeFinder();")
      self.webview.keyboardDisplayRequiresUserAction = true
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
  end
end
