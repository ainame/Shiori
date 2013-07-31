class BookMarkScreen < PM::TableScreen
  module StaticMenu
    def default_menu
      # this method called before on_load, so you should initialize variable
      @user_link_url ||= "https://github.com"
      [{
          title: "Github Menu",
          cells: [{
              title: "DashBoard",
              cell_style: UITableViewCellStyleDefault,
              cell_identifier: "GithubMenu",
              cell_class: BookMark::CustomTableCell,
              action: :select_default_menu,
              arguments: "https://github.com",
            },{
              title: "Star",
              cell_style: UITableViewCellStyleDefault,
              cell_identifier: "GithubMenu",
              cell_class: BookMark::CustomTableCell,
              action: :select_default_menu,
              arguments: "https://github.com/stars",
            },{
              title: "YourRepositories",
              cell_style: UITableViewCellStyleDefault,
              cell_identifier: "GithubMenu",
              cell_class: BookMark::CustomTableCell,
              action: :select_default_menu,
              arguments: user_link_url + "?tab=repositories",
            }
          ]
        }]    
    end

    def setting_menu
      [{
          title: "Setting Menu",
          cells: [{
              title: "Setting",
              cell_style: UITableViewCellStyleDefault,
              cell_identifier: "SettingMenu",
              cell_class: BookMark::CustomTableCell,
              action: :open_setting_screen,
            },{
              title: "Lisence",
              cell_style: UITableViewCellStyleDefault,
              cell_identifier: "SettingMenu",
              cell_class: BookMark::CustomTableCell,
              action: :select_default_menu,
              arguments: "https://github.com/stars",
            },
          ]
        }]    
    end
  end
end
