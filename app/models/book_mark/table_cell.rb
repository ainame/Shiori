class BookMark < NanoStore::Model
  class TableCell
    CELL_IDENTIFIER = 'book_mark'

    def initialize(book_mark)
      @book_mark = book_mark
    end

    def render
      {
        cell_style: UITableViewCellStyleSubtitle,
        cell_class: CustomTableCell,
        title: @book_mark.line_of_code,
        subtitle: "L#{@book_mark.line}: #{@book_mark.file_name}",
        cell_identifier: CELL_IDENTIFIER,
        editing_style: :delete,
        action: :select_book_mark,
        key: @book_mark.key,
        arguments: @book_mark,
      }
    end
  end
end
