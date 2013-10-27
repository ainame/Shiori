class BookMarkScreen < PM::TableScreen
  include BookMarkScreen::StaticMenu

  attr_accessor :table_data, :user_link_url
  searchable placeholer: "github code"

  title 'Shiori'

  # hack to resizing UITableView
  def set_up_table_view
    self.table_view
    _table_view = self.create_table_view_from_data(self.table_data)
    adjusted_frame = self.view.bounds
    adjusted_frame.size.width = app_delegate.panels.leftVisibleWidth
    _table_view.frame = adjusted_frame
    self.view = UIView.new
    self.view.addSubview(_table_view)
  end

  def table_data
    @table_data = create_book_marks_table_data
  end

  def on_load
    update_table_data
  end

  def create_book_marks_table_data
    default_menu + (create_sections || []) + setting_menu
  end

  def create_sections
    book_marks = BookMark.all
    sections = BookMark::TableSection.create_sections(book_marks)
    sections.map(&:render)
  end

  def select_book_mark(book_mark)
    app_delegate.viewer.open_url(book_mark.url)
    app_delegate.panels.toggleLeftPanel(nil)
  end

  def select_default_menu(url)
    app_delegate.viewer.open_url(url)
    app_delegate.panels.toggleLeftPanel(nil)
  end

  def open_screen_by_args(pm_class)
    app_delegate.panels.centerPanel = pm_class.new(nav_bar: true).navigation_controller
    app_delegate.panels.toggleLeftPanel(nil)
  end

  def delete_row(index_paths, animated = true)
    cell = @table_data[index_paths.section][:cells][index_paths.row]
    delete_from_db(cell[:key])
    @table_data = create_book_marks_table_data
    update_table_data
  end

  def delete_from_db(key)
    BookMark.find_by_key(key).delete
  end
end
