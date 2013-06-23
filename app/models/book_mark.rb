class BookMark < NanoStore::Model
  attributes :url, :repository_name, :file_name, :author, :line, :line_of_code
end
