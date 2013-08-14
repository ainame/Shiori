class HatenaBookmarkScreen < PM::Screen
  def on_load
    self.view.backgroundColor = UIColor.whiteColor

    if HTBHatenaBookmarkManager.sharedManager.authorized
      HTBHatenaBookmarkManager.sharedManager.getMyEntryWithSuccess(
        lambda { |entry|
          PM.logger.info entry
        },
        failure: lambda { |error| }
      )

      HTBHatenaBookmarkManager.sharedManager.getMyTagsWithSuccess(
        lambda { |tags|
          PM.logger.info tags
        },
        failure: lambda { |error| }
      )

      url = NSURL.URLWithString('http://mixi.jp')
      viewController = HTBHatenaBookmarkViewController.alloc.init
      viewController.URL = url
      self.presentViewController(viewController, animated:true, completion:nil)
    end
  end
end
