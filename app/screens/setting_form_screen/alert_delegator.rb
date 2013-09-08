class SettingFormScreen < PM::GroupedTableScreen
  class AlertDelegator

    TAG_MAP = {
      1 => Payment,
      2 => InitializeHatenaBookMark,
      3 => DeleteAllBookMark,
    }
    ALERT_OK_BUTTON = 1

    def alertView(alert_view, clickedButtonAtIndex: button_index)
      if button_index == ALERT_OK_BUTTON
        TAG_MAP[alert_view.tag].execute
      end
    end

  end
end
