describe BookMark::TableCell do
  before do
    NanoStore.shared_store = NanoStore.store(:file, App.documents_path + '/test_store.db')
  end

  after do
    path = App.documents_path + "/tes_store.db"
    File.delete(path) rescue nil
  end

  describe 'create instance' do
    before do
      params = {
        repository_name: 'motion-mode',
        file_name: 'motion-mode.el',
        url: 'http://github.com/ainame/motion-mode/blob/master/motion-mode.el',
      }
      @book_mark = BookMark.new(params)
    end

    describe 'new' do
      it 'should create' do
        b = BookMark::TableCell.new(@book_mark)
        b.class.should == BookMark::TableCell
      end
    end

    describe 'render' do
      it 'should return Hash' do
        b = BookMark::TableCell.new(@book_mark)
        b.render.should == {
          title: @book_mark.file_name,
          cell_identifier: BookMark::TableCell::CELL_IDENTIFIER,
        }
      end
    end
  end
end
