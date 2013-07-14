class BookMark < NanoStore::Model
  class TableSection
    class ArgumentError < StandardError; end
    attr_reader :author, :title, :book_marks

    def initialize(book_marks)
      raise ArgumentError unless book_marks.kind_of?(Array)
      @book_marks = book_marks
      @title = @book_marks.first.repository_name
      @author = @book_marks.first.author
   end

    def render
      {
        title: "#{@author}/#{@title}",
        cells: render_cells,
      }
    end

    def render_cells
      @book_marks.map do |b|
        BookMark::TableCell.new(b).render
      end      
    end

    class << self
      def create_sections(book_marks)
        book_marks.group_by do |b|
          b.repository_name
        end.map do |title, book_marks_of_section|
          new(book_marks_of_section)
        end.sort do |a,b|
          a.author <=> b.author
        end
      end
    end
  end
end
