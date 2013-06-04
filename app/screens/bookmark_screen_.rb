class BookMarkScreen < PM::TableScreen
  searchable placeholer: "github code"

  def table_data
    s = []

    s << introduction_section
    s << judging_tools_section
    s << bibliography_section
  end

  def judging_tools_section
    {
      title: "Judging Tools",
      cells:
      [{
          title: "Flavor Wheel",
          cell_identifier: "ImageCell",
          image: { image: UIImage.imageNamed("flavor_wheel_thumb.png") },
        }]
    }
  end

  def introduction_section
    {
      title: nil,
      cells:
      [{
          title: "Introduction",
          cell_identifier: "ImageCell",
          image: { image: UIImage.imageNamed("ba_logo_thumb.png") },
        }]
    }
  end

  def bibliography_section
    {
      title: "Extras",
      cells:
      [{
          title: "Bibliography",
          cell_identifier: "NonImageCell",
        }]
    }
  end
end
