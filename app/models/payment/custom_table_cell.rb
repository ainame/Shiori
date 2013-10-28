module Payment
  class CustomTableCell < ::Shiori::CustomTableCell
    def text_label_options
      return NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading,
    end

    def detail_text_label_options
      return NSStringDrawingTruncatesLastVisibleLine
    end
  end
end
