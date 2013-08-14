# -*- coding: utf-8 -*-

class SettingScreen < PM::Screen
  title 'Setting Menu'
  ALERT_OK_BUTTON = 1

  def on_load
    NSNotificationCenter.defaultCenter.addObserver(
      self, selector:'showOAuthLoginView:', name: KHTBLoginStartNotification, object: nil
    )
    set_hatena_button
    set_nav_button
    set_delete_button
    self.view.backgroundColor = UIColor.whiteColor
  end

  def set_delete_button
    center_x = App.bounds.size.width / 2
    @label  = add UILabel.new, {
      center: CGPointMake(center_x - 125, 250),
      style_id: 'setting-screen-delete-button-label'
    }
    @label.text = 'BookMark'
    @label.sizeToFit
    @button = add UIButton.buttonWithType(UIButtonTypeRoundedRect), {
      center: CGPointMake(center_x - 125, 300),
      background_color: UIColor.redColor,
      style_id: 'setting-screen-delete-button'
    }
    @button.setTitle('Delete All Bookmarks', forState: UIControlStateNormal)
    @button.setTitleColor(UIColor.whiteColor, forState: UIControlStateNormal)
    @button.sizeToFit
    @button.addTarget(self, action: :alert,
      forControlEvents: UIControlEventTouchUpInside)
  end

  def set_hatena_button
    center_x = App.bounds.size.width / 2
    @label  = add UILabel.new, {
      center: CGPointMake(center_x - 125, 500),
      style_id: 'setting-screen-delete-button-label'
    }
    @label.text = 'Hatena BookMark'
    @label.sizeToFit
    @button = add UIButton.buttonWithType(UIButtonTypeRoundedRect), {
      center: CGPointMake(center_x - 125, 550),
      background_color: UIColor.blueColor,
      style_id: 'setting-screen-delete-button'
    }
    @button.setTitle('Login', forState: UIControlStateNormal)
    @button.setTitleColor(UIColor.whiteColor, forState: UIControlStateNormal)
    @button.sizeToFit
    @button.addTarget(self, action: :on_login,
      forControlEvents: UIControlEventTouchUpInside)
  end

  def alert
    alert = UIAlertView.new.tap do |a|
      a.title   = 'Confirm'
      a.message = 'Can I delete your all bookmarks?'
      a.delegate = self
      a.addButtonWithTitle("Cancel")
      a.addButtonWithTitle("OK")
    end
    alert.show
  end

  def alertView(alert_view, clickedButtonAtIndex: button_index)
    if button_index == ALERT_OK_BUTTON
      delete_all_book_marks
    end
  end

  def delete_all_book_marks
    begin 
      BookMark.all.each {|b| BookMark.delete(url: b.url) }
      app_delegate.book_mark.update_table_data 
      BW::App.alert('Delete Successful!')     
    rescue
      BW::App.alert('Delete Failure...')
    end
  end

  def on_login
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

  def toggle_left_panel
    app_delegate.panels.centerPanel = app_delegate.viewer.navigation_controller
    app_delegate.panels.toggleLeftPanel(nil)
  end

  def set_nav_button
    custom_view = UIButton.buttonWithType(UIButtonTypeCustom).tap do |b|
      b.setImage(UIImage.imageNamed("iconbeast/bookmark"), forState: UIControlStateNormal)
      b.frame = CGRectMake(0,0,25,25)
      b.addTarget(self, action: :toggle_left_panel, forControlEvents: UIControlEventTouchUpInside)
    end
    button = UIBarButtonItem.alloc.initWithCustomView(custom_view)
    self.navigationItem.leftBarButtonItem = button
  end

  # objective-c method
  def showOAuthLoginView(notification)
    req = notification.object
    navigationController = UINavigationController.alloc.initWithNavigationBarClass(HTBNavigationBar, toolbarClass:nil)
    viewController = HTBLoginWebViewController.alloc.initWithAuthorizationRequest(req)
    navigationController.viewControllers = [viewController]
    self.presentViewController(navigationController, animated:true, completion:nil)
  end
end
