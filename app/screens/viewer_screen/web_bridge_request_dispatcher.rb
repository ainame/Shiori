class ViewerScreen < PM::WebScreen
  class WebBridgeRequestDispatcher
    BRIDGE_URL_SCHEME = 'shiori-webview'

    attr_reader :url, :method, :params

    RPC_MAP = {
      'clickLineOfCode' => 'ClickLineOfCode'
    }

    def initialize(request)
      @url = request.URL
      return unless web_bridge_request?

      @method, message = extract_method_and_message
      @params  = BW::JSON.parse(message)
      PM.logger.debug("passed URL - #{@url.scheme}://#{@url.host} from WebView") if RUBYMOTION_ENV == "development"
    end

    def web_bridge_request?
      @url.scheme == BRIDGE_URL_SCHEME
    end

    def execute
      klass = self.class.const_get(RPC_MAP[method]) rescue PM.logger.debug($!)
      klass.new.execute(params) if klass
    end

    private
    def extract_method_and_message
      @url.host.match(/(.*?)(\{.*\})/).captures
    end
  end
end
