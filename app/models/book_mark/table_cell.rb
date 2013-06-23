class BookMark < NanoStore::Model
  class TableCell
    CELL_IDENTIFIER = 'book_mark'

    def initialize(book_mark)
      @book_mark = book_mark
    end

    def render
      {
        cell_style: UITableViewCellStyleSubtitle,
        title: @book_mark.file_name,
        subtitle: "L#{@book_mark.line}",
        cell_identifier: CELL_IDENTIFIER,
        action: :select_book_mark,
        key: @book_mark.key,
        arguments: @book_mark,
      }
    end
  end
end
