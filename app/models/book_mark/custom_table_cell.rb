class BookMark < NanoStore::Model
  class CustomTableCell < ::Shiori::CustomTableCell
    def layoutSubviews
      super
      self.accessoryType = UITableViewCellAccessoryDisclosureIndicator
      self.textLabel.numberOfLines = 0
      self.textLabel.font = UIFont.systemFontOfSize(UIFont.systemFontSize)
    end

    def text_label_options
      return NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading,
    end

    def detail_text_label_options
      return NSStringDrawingTruncatesLastVisibleLine
    end
  end
end
