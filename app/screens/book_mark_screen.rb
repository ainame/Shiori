class BookMarkScreen < PM::TableScreen
  attr_accessor :table_data, :user_link_url
  searchable placeholer: "github code"
  refreshable callback: :on_refresh

  title 'Shiori'

  def on_load
    @table_data = create_sections    
    update_table_data
  end

  def on_refresh
    @table_data = create_sections    
    end_refreshing
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
    self.splitViewController.detail_screen.open_url(book_mark.url)
    app_delegate.popover_screen.dismissPopoverAnimated(true)
  end

  def select_default_menu(url)
    self.splitViewController.detail_screen.open_url(url)
    app_delegate.popover_screen.dismissPopoverAnimated(true)
  end

  private
  def delete_cell(index_paths, animated = true)
    cell = @table_data[index_paths.section][:cells][index_paths.row]
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
