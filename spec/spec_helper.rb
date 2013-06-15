class NSIndexPath
  attr_accessor :section, :row
end

module SpecHelper
  def create_index_path(section, row)
    index_path = NSIndexPath.new
    index_path.section = section
    index_path.row     = row
    return index_path
  end
  module_function :create_index_path
end
