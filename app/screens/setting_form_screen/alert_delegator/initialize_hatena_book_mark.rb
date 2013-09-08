class SettingFormScreen < PM::GroupedTableScreen
  class AlertDelegator
    class InitializeHatenaBookMark
      def self.execute
        new
      end

      def initialize
        NSNotificationCenter.defaultCenter.addObserver(
          self,
          selector:'showOAuthLoginView:',
          name: KHTBLoginStartNotification,
          object: nil
        )
        sign_in
      end

      def sign_in
        HTBHatenaBookmarkManager.sharedManager.logout
        HTBHatenaBookmarkManager.sharedManager.authorizeWithSuccess(
          lambda {
            UIAlertView.new.tap do |a|
              a.message = 'Login Succeed!'
              a.addButtonWithTitle("OK")
            end.show
          },
          failure: lambda {|error|
            PM.logger.warn(error)
            NSLog(error.localizedDescription)
          }
        )    
      end

      # objective-c method
      def showOAuthLoginView(notification)
        req = notification.object
        navigationController = UINavigationController.alloc.initWithNavigationBarClass(HTBNavigationBar, toolbarClass:nil)
        viewController = HTBLoginWebViewController.alloc.initWithAuthorizationRequest(req)
        navigationController.viewControllers = [viewController]

        BW::App.shared.delegate.panels.centerPanel.
          presentViewController(navigationController, animated:true, completion:nil)
      end
    end
  end
end
