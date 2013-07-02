class AppDelegate < PM::Delegate
  attr_reader :book_mark, :viewer, :book_mark_button, :panels

  def on_load(app, options)
    db_path = App.documents_path + '/book_marks.db'
    NanoStore.shared_store = NanoStore.store :file, db_path

    @panels = JASidePanelController.new
    @viewer = ViewerScreen.new(nav_bar: true)
    @book_mark = BookMarkScreen.new
    @viewer.on_load
    @book_mark.on_load

    @panels.leftPanel = @book_mark
    @panels.centerPanel = @viewer.navigation_controller

    frame = UIScreen.mainScreen.bounds
    self.window = UIWindow.alloc.initWithFrame(frame)
    self.window.rootViewController = @panels
    self.window.makeKeyAndVisible
  end
end
