class BookMarkScreen < PM::TableScreen
  attr_accessor :table_data, :user_link_url
  searchable placeholer: "github code"

  title 'Shiori'

  # hack to resizing UITableView
  def set_up_table_view
    _table_view = self.create_table_view_from_data(self.table_data)
    adjusted_frame = self.view.bounds
    adjusted_frame.size.width = app_delegate.panels.leftVisibleWidth
    _table_view.frame = adjusted_frame
    self.view = UIView.new
    self.view.addSubview(_table_view)
  end

  def on_load
    @table_data = create_sections    
    update_table_data
  end

  def table_data
    @table_data ? default_menu.concat(@table_data) : default_menu
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

  def delete_row(index_paths, animated = true)
    # index_paths.section should subtract 1 about default menu
    cell = @table_data[index_paths.section - 1][:cells][index_paths.row]
    delete_from_db(cell[:key])
    @table_data = create_sections
    update_table_data
  end

  def delete_from_db(key)
    BookMark.find_by_key(key).delete
  end

  def default_menu
    # this method called before on_load, so you should initialize variable
    @user_link_url ||= "https://github.com"
    [{
        title: "Github Menu",
        cells: [{
            title: "DashBoard",
            cell_style: UITableViewCellStyleDefault,
            cell_identifier: "GithubMenu",
            action: :select_default_menu,
            arguments: "https://github.com",
          },{
            title: "Star",
            cell_style: UITableViewCellStyleDefault,
            cell_identifier: "GithubMenu",
            action: :select_default_menu,
            arguments: "https://github.com/stars",
          },{
            title: "YourRepositories",
            cell_style: UITableViewCellStyleDefault,
            cell_identifier: "GithubMenu",
            action: :select_default_menu,
            arguments: user_link_url + "?tab=repositories",
          }
        ]
      }]    
  end
end
