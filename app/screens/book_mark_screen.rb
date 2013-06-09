class BookMarkScreen < PM::TableScreen
  searchable placeholer: "github code"
  refreshable callback: :on_refresh

  def on_load
    @table_data = create_sections    
    update_table_data
  end

  def table_data
    @table_data
  end

  def on_refresh
    @table_data = create_sections    
    end_refreshing
    update_table_data
  end

  def create_sections
    @book_marks = BookMark.all
    @sections = BookMark::TableSection.create_sections(@book_marks)
    @sections.map(&:render)
  end
end
