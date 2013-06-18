class BookMark < NanoStore::Model
  class TableCell
    CELL_IDENTIFIER = 'book_mark'

    def initialize(book_mark)
      @book_mark = book_mark
    end

    def render
      {
        :title => @book_mark.file_name,
        :cell_identifier => CELL_IDENTIFIER,
        :action => :select_book_mark,
        :key => @book_mark.key,
        :arguments => @book_mark,
      }
    end
  end
end
