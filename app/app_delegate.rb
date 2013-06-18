class AppDelegate < PM::Delegate
  attr_reader :viewer, :popover_screen

  def on_load(app, options)
    db_path = App.documents_path + '/book_marks.db'
    NanoStore.shared_store = NanoStore.store :file, db_path
    @viewer = ViewerScreen.new(nav_bar: true)
    open_split_screen BookMarkScreen, @viewer
  end

  # hack to get popoverController 
  def splitViewController(svc, willHideViewController: vc, withBarButtonItem: button, forPopoverController: pc)
    @popover_screen = pc
    button.title = vc.title
    svc.detail_screen.navigationItem.leftBarButtonItem = button;
  end
end
