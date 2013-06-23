class AppDelegate < PM::Delegate
  attr_reader :book_mark, :viewer, :popover_screen, :book_mark_button

  def on_load(app, options)
    db_path = App.documents_path + '/book_marks.db'
    NanoStore.shared_store = NanoStore.store :file, db_path

    @viewer = ViewerScreen.new(nav_bar: true)
    @book_mark = BookMarkScreen.new
    open_split_screen @book_mark, @viewer
  end

  # hack to get popoverController 
  def splitViewController(svc, willHideViewController: vc, withBarButtonItem: button, forPopoverController: pc)
    @popover_screen = pc
    button.customView = UIButton.buttonWithType(UIButtonTypeCustom).tap do |b|
      b.setImage(UIImage.imageNamed("iconbeast/bookmark"), forState: UIControlStateNormal)
      b.frame = CGRectMake(0,0,25,25)
      b.addTarget(svc.detail_screen, action: :popup_book_mark, forControlEvents: UIControlEventTouchUpInside)
    end
    svc.detail_screen.navigationItem.leftBarButtonItem = button
  end

  def splitViewController(svc, popoverController:pc, willPresentViewController:aViewController)
    aViewController.on_load
  end
end
