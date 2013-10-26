module TogglePanelButton
  def toggle_left_panel
    app_delegate.panels.centerPanel = app_delegate.viewer.navigation_controller
    app_delegate.panels.toggleLeftPanel(nil)
  end

  def set_toggle_panel_button
    custom_view = UIButton.buttonWithType(UIButtonTypeCustom).tap do |b|
      b.setImage(UIImage.imageNamed("iconbeast/bookmark"), forState: UIControlStateNormal)
      b.frame = CGRectMake(0,0,25,25)
      b.addTarget(self, action: :toggle_left_panel, forControlEvents: UIControlEventTouchUpInside)
    end
    button = UIBarButtonItem.alloc.initWithCustomView(custom_view)
    self.navigationItem.leftBarButtonItem = button
  end
end
