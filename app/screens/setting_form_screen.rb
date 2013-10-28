# -*- coding: utf-8 -*-
class SettingFormScreen < PM::GroupedTableScreen
  include TogglePanelButton

  title 'Settings'

  def on_load
    set_toggle_panel_button
    @alert_delegator = SettingFormScreen::AlertDelegator.new
    update_table_data
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
            cell_class: Payment::CustomTableCell,
            title: '作者に小ラーメンをおごる',
            action: :alert,
            arguments: {
              message: '作者に小ラーメンをおごりますか？',
              tag: 1,
            }
          },{
            cell_class: Payment::CustomTableCell,
            title: '作者に小ラーメン豚Wをおごる',
            action: :alert,
            arguments: {
              message: '作者に小ラーメン豚Wをおごりますか？',
              tag: 1,
            }
          },{
            cell_class: Payment::CustomTableCell,
            title: '作者に大ラーメン豚Wをおごる',
            action: :alert,
            arguments: {
              message: '作者に大ラーメン豚Wをおごりますか？',
              tag: 1,
            }
          }
        ],
      },{
        title: 'Hatena Bookmark',
        cells: [{
            cell_class: Shiori::CustomTableCell,
            title: 'Connect',
            action: :alert,
            arguments: {
              message: 'Sign in this app with Hatena account',
              tag: 2,
            }
          }
        ],
      },
    ]

    @table_data = is_premium_user ? menu + delete_book_mark_menu : menu
  end

  def is_premium_user
    true
  end

  def delete_book_mark_menu
    [{
        title: 'Bookmark',
        cells: [{
            cell_class: Shiori::CustomTableCell,
            title: 'Delete all bookmarks',
            action: :alert,
            arguments: {
              message: 'Can I delete your all bookmarks?',
              tag: 3,
            }
          }
        ],
      }]
  end

  def tableView(tableView, titleForFooterInSection:section)
    case section
    when 0
      'ラーメンを作者に奢るとアプリ内ブックマーク削除機能が開放されます'
    end
  end

  OUTER_PADDING = 20
  def tableView(tableView, heightForRowAtIndexPath:indexPath)
    cell = tableView(tableView, cellForRowAtIndexPath:indexPath)
    bounds = CGSizeMake(tableView.frame.size.width, tableView.frame.size.height)
    return cell.own_height(bounds) + OUTER_PADDING
  end
end
