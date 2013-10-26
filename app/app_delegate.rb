class AppDelegate < PM::Delegate
  attr_reader :book_mark, :viewer, :book_mark_button, :panels

  def on_load(app, options)
    initialize_hatena_oauth

    db_path = App.documents_path + '/book_marks.db'
    NanoStore.shared_store = NanoStore.store :file, db_path

    @panels = JASidePanelController.new
    @viewer = ViewerScreen.new(nav_bar: true)
    @book_mark = BookMarkScreen.new

    @panels.leftPanel = @book_mark
    @panels.centerPanel = @viewer.navigation_controller

    frame = UIScreen.mainScreen.bounds
    self.window = UIWindow.alloc.initWithFrame(frame)
    self.window.rootViewController = @panels
    self.window.makeKeyAndVisible
  end

  private
  def initialize_hatena_oauth
    HTBHatenaBookmarkManager.sharedManager.setConsumerKey(
      MY_ENV['hatena_consumer_key'],
      consumerSecret: MY_ENV['hatena_consumer_secret']
    )
  end

end

# for ios7
if UIDevice.currentDevice.ios7?
  class JASidePanelController < UIViewController
    def prefersStatusBarHidden
      true
    end
  end
end
