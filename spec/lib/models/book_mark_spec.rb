describe BookMark do
  before do
    NanoStore.shared_store = NanoStore.store(:file, App.documents_path + '/test_store.db')
  end

  after do
    path = App.documents_path + "/tes_store.db"
    File.delete(path) rescue nil
  end

  # describe 'instantize with no arugments' do
  #   describe 'class' do
  #     it 'should raise error' do
  #       should.raise { BookMark.new }
  #     end
  #   end
  # end

  describe 'instantize with arugments' do
    before do
      params = {
        repository_name: 'motion-mode',
        url: 'http://github.com/ainame/motion-mode/blob/master/motion-mode.el',
        file_name: 'motion-mode.el'
      }
      @b = BookMark.new(params)
    end

    describe 'class' do
      it 'should be a instance' do
        @b.class.should == BookMark
      end
    end

    describe 'attributes' do
      it 'should have uuid' do
        @b.key.should.not == nil
      end

      it 'should be setted repository_name' do
        @b.repository_name.should == 'motion-mode'
      end

      it 'should be setted url' do
        @b.url.should == 'http://github.com/ainame/motion-mode/blob/master/motion-mode.el'
      end

      it 'should be setted file_name' do
        @b.file_name.should == 'motion-mode.el'
      end
    end

    describe 'save' do
      it 'can be store' do
        @b.save
        b = BookMark.find(:url => @b.url).first
        b.key.should.not == @b.key
        b.url.should == @b.url
      end
    end

  end
end
