class BookMark < NanoStore::Model
  attributes :url, :repository_name, :file_name, :author, :line
end
