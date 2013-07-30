class BookMark::CustomTableCell < PM::TableViewCell
  def layoutSubviews
    super
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator
  end
end
