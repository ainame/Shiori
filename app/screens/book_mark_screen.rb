class BookMarkScreen < PM::TableScreen
  include BookMark::TableViewDelegate
  attr_accessor :table_data
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
    @table_data
  end

  def delete_from_db(key)
    BookMark.find_by_key(key).delete
  end

  def select_book_mark(book_mark)
    self.splitViewController.detail_screen.open_url(book_mark.url)
  end

  def create_sections
    book_marks = BookMark.all
    sections = BookMark::TableSection.create_sections(book_marks)
    sections.map(&:render)
  end
end
