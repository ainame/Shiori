# -*- coding: utf-8 -*-
class SettingFormScreen < PM::GroupedTableScreen
  include TogglePanelButton

  title 'Settings'

  def on_load
    set_toggle_panel_button
    @alert_delegator = SettingFormScreen::AlertDelegator.new
  end

  def alert(params)
    alert = UIAlertView.new.tap do |a|
      a.title   = 'Confirm'
      a.message = params[:message]
      a.tag = params[:tag]
      a.delegate = @alert_delegator
      a.addButtonWithTitle("Cancel")
      a.addButtonWithTitle("OK")
    end
    alert.show
  end

  def table_data
    menu = [{
        title: 'Payment',
        cells: [{
            title: '作者にラーメン二郎小ラーメンを奢る',
            action: :alert,
            arguments: {
              message: '作者にラーメン二郎',
            }
          },{
            title: '作者にラーメン二郎小ラーメン豚Wを奢る',
            action: :alert,
            arguments: {
              message: '作者にラーメン二郎',
            }
          },{
            title: '作者にラーメン二郎大ラーメン豚Wを奢る',
            action: :alert,
            arguments: {
              message: '作者にラーメン二郎',
            }
          }
        ],
      },{
        title: 'Hatena Bookmark',
        cells: [{
            title: 'Connect',
            action: :alert,
            arguments: {
              message: 'Sign in this app with Hatena account',
            }
          }
        ],
      },
    ]

    is_premium_user ? menu + delete_book_mark_menu : menu
  end
  
  def is_premium_user
    true
  end

  def delete_book_mark_menu
    [{
        title: 'Bookmark',
        cells: [{
            title: 'Delete all bookmarks',
            action: :alert,
            arguments: {
              message: 'Can I delete your all bookmarks?',
              tag: 1,
            }
          }
        ],
      }]  
  end

  def tableView(tableView, titleForFooterInSection:section)
    case section
    when 0
      'ラーメン二郎を作者に奢るとアプリ内ブックマーク削除機能が開放されます'
    end
  end
end
