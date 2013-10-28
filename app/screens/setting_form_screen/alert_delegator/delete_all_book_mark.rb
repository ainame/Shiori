class SettingFormScreen < PM::GroupedTableScreen
  class AlertDelegator
    module DeleteAllBookMark
      def self.execute
        begin
          BookMark.all.each {|b| BookMark.delete(url: b.url) }
          BW::App.shared.delegate.book_mark.update_table_data
          BW::App.alert('Delete Successful!')
        rescue
          BW::App.alert('Delete Failure...')
        end
      end
    end
  end
end
