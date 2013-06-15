describe BookMark::TableViewDelegate do
  before do
    class Dummy
      include BookMark::TableViewDelegate
      def initialize(table_data)
        @table_data = table_data
        @is_called_delete_from_db = false
        @is_called_update_table_data = false
      end

      def delete_from_db(key)
        @is_called_delete_from_db = true
      end

      def update_table_data
        @is_called_update_table_data = true
      end
    end
  end

  describe "empty table_data" do
    before do
      @dummy_table_data = []
      @subject = Dummy.new(@dummy_table_data)
    end

    describe "table_data" do
      it "should return " do
        @subject.table_data.should == @dummy_table_data
      end
    end

    describe "delete_cell" do
      it "should raise error for access nil data" do 
        index_path = SpecHelper.create_index_path(0,0)
        should.raise(NoMethodError) {
          @subject.delete_cell(index_path)
        }
        @subject.instance_variable_get(:@is_called_delete_from_db).should == false
        @subject.instance_variable_get(:@is_called_update_table_data).should == false
      end
    end
  end

  describe "no section table_data" do
    before do
      @dummy_table_data = [
        {
          cells: [
            { title: 'aaa' }
          ]
        }
      ]
      @subject = Dummy.new(@dummy_table_data)
    end

    describe "table_data" do
      it "should return " do
        @subject.table_data.should == @dummy_table_data
      end
    end

    describe "delete_cell" do
      it "should raise error for access nil data" do 
        index_path = SpecHelper.create_index_path(0,0)
        @subject.delete_cell(index_path)
        @subject.table_data.should == [{cells: []}]
        @subject.instance_variable_get(:@is_called_delete_from_db).should == true
        @subject.instance_variable_get(:@is_called_update_table_data).should == true
      end
    end
  end
end
