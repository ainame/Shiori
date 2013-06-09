describe BookMark::TableSection do
  before do
    NanoStore.shared_store = NanoStore.store(:file, App.documents_path + '/test_store.db')
  end

  after do
    path = App.documents_path + "/tes_store.db"
    File.delete(path) rescue nil
  end
  
  describe 'one section' do
    before do
      params = {
        repository_name: 'motion-mode',
        file_name: 'motion-mode.el',
        url: 'http://github.com/ainame/motion-mode/blob/master/motion-mode.el',
      }
      @book_mark = BookMark.new(params)
    end

    describe 'new' do
      it 'should create instance' do
        should.raise(BookMark::TableSection::ArgumentError) {
          BookMark::TableSection.new(@book_mark)
        }
      end

      it 'should create instance' do
        s = BookMark::TableSection.new([@book_mark])
        s.class.should == BookMark::TableSection
      end
    end
  end

  describe 'three section' do
    before do
      @book_marks = []
      3.times do |idx|
        params = {
          repository_name: "motion-mode#{idx}",
          file_name: 'motion-mode.el',
          url: 'http://github.com/ainame/motion-mode/blob/master/motion-mode.el',
        }
        @book_marks << BookMark.new(params)
      end

      @sections = BookMark::TableSection.create_sections(@book_marks)
    end

    describe '.create_sections' do
      it 'should create instance array' do
        @sections.class.should == Array
        @sections.first.class.should == BookMark::TableSection
      end
    end

    describe 'render' do
      it 'should return Hash' do
        rendered_section = @sections.map(&:render)
        rendered_section.class.should == Array
        rendered_section.each do |s|
          s.class.should == Hash
        end
      end
    end
  end
end
