class ViewerScreen < PM::WebScreen
  class WebBridgeRequestDispatcher
    class ClickLineOfCode
      def execute(params)
        BookMark.new(params).save
        BW::App.shared.delegate.book_mark.update_table_data
      end
    end
  end
end
