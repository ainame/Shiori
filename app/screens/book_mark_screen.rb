class BookMarkScreen < PM::TableScreen
  searchable placeholer: "github code"

  def table_data
    book_marks = BookMark.all
  end

  # def judging_tools_section
  #   {
  #     title: "Judging Tools",
  #     cells:
  #     [{
  #         title: "Flavor Wheel",
  #         cell_identifier: "ImageCell",
  #         image: { image: UIImage.imageNamed("flavor_wheel_thumb.png") },
  #       }]
  #   }
  # end
end
