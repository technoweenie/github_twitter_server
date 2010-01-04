require File.expand_path("../../spec_helper", __FILE__)

describe "Creating the tables for a model" do
  before do
    @klass = Class.new do
      include Friendly::Document

      def self.table_name; "stuffs"; end

      attribute :name,    String
      attribute :user_id, Friendly::UUID

      indexes [:name, :created_at]
      indexes :user_id
    end

    @klass.create_tables!
    @schema         = Friendly.db.schema(:stuffs)
    @table          = Hash[*@schema.map { |s| [s.first, s.last] }.flatten]
    @index_schema   = Friendly.db.schema(:index_stuffs_on_name_and_created_at)
    @index_table    = Hash[*@index_schema.map { |s| [s.first, s.last] }.flatten]
    @id_idx_schema  = Friendly.db.schema(:index_stuffs_on_user_id)
    @id_index_table = Hash[*@id_idx_schema.map { |s| [s.first, s.last] }.flatten]
  end

  after do
    Friendly.db.drop_table(:stuffs) 
    Friendly.db.drop_table(:index_stuffs_on_name_and_created_at) 
  end

  it "creates a table for the document" do
    @table.keys.length.should == 5
    @table[:added_id][:db_type].should == "int(11)"
    @table[:added_id][:primary_key].should be_true
    @table[:id][:db_type].should == "binary(16)"
    @table[:attributes][:db_type].should == "text"
    @table[:created_at][:db_type].should == "datetime"
    @table[:updated_at][:db_type].should == "datetime"
  end

  it "creates a table for each index" do
    @index_table.keys.length.should == 3
    @index_table[:name][:db_type].should == "varchar(255)"
    @index_table[:name][:primary_key].should be_true
    @index_table[:created_at][:db_type].should == "datetime"
    @index_table[:created_at][:primary_key].should be_true
    @index_table[:id][:db_type].should == "binary(16)"
    @index_table[:id][:primary_key].should be_true
  end

  it "knows how to create an index for a field of a custom type" do
    @id_index_table.keys.length.should == 2
    @id_index_table[:user_id][:db_type].should == "binary(16)"
    @id_index_table[:user_id][:primary_key].should be_true
    @id_index_table[:id][:db_type].should == "binary(16)"
    @id_index_table[:id][:primary_key].should be_true
  end

  it "doesn't raise if the tables already exist" do
    lambda {
      @klass.create_tables!
    }.should_not raise_error
  end
end
