class BookMark < NanoStore::Model
  module TableViewDelegate
    def table_data
      @table_data
    end

    def delete_cell(index_paths, animated = true)
      cell = @table_data[index_paths.section][:cells][index_paths.row]
      delete_from_db(cell[:key])
      @table_data[index_paths.section][:cells].delete_at(index_paths.row)
      update_table_data
    end

    def delete_cell_at(section, row)
      @tabel_data[section][:cells].delete_at(row)
      update_table_data
    end
  end
end
