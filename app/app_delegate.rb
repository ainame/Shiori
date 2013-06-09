class AppDelegate < PM::Delegate
  def on_load(app, options)
    db_path = App.documents_path + '/book_marks.db'
    NanoStore.shared_store = NanoStore.store :file, db_path
    open_split_screen BookMarkScreen, GithubScreen
  end
end
