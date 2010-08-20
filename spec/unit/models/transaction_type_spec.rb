require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe TransactionType do
  it "validates id and name" do
    id = TransactionType::TYPES_TO_IDS[:DEBIT]
    tt = TransactionType.new(id)
    tt.valid?.should == true
  end
  
  it "finds by id" do
    tt = TransactionType.find(TransactionType::TYPES_TO_IDS[:DEBIT])
    tt.name.should == "DEB"
    tt.type.should == :DEBIT
  end
  
  it "finds by name" do
    tt = TransactionType.find_by_name('DEB')
    tt.id.should == TransactionType::NAMES_TO_IDS['DEB']
    tt.type.should == :DEBIT
  end
  
  it "finds by type" do
    tt = TransactionType.find_by_type(:DEBIT)
    tt.id.should == TransactionType::TYPES_TO_IDS[:DEBIT]
    tt.name.should == "DEB"
  end
  
  it "answers to is_x? appropriately" do
    tt = TransactionType.find_by_type(:DEBIT)
    tt.is_debit?.should == true
    tt.is_credit?.should == false
  end
    
  it "class method of type creates new with that type" do
    TransactionType.debit.is_debit?.should == true
    TransactionType.int.is_int?.should == true
  end
  
  it "finds all all types" do
    TransactionType::TYPES.each do |type|
      TransactionType.find_by_type(type).should_not == nil
    end
  end
end