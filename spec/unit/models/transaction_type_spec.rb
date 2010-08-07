require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe TransactionType do
  it "validates id and name" do
    id = TransactionType::TYPES_TO_IDS[:debit]
    tt = TransactionType.new(id)
    tt.valid?.should == true
  end
  
  it "finds by id" do
    tt = TransactionType.find(TransactionType::TYPES_TO_IDS[:debit])
    tt.name.should == "DEB"
    tt.type.should == :debit
  end
  
  it "finds by name" do
    tt = TransactionType.find_by_name('DEB')
    tt.id.should == TransactionType::NAMES_TO_IDS['DEB']
    tt.type.should == :debit
  end
  
  it "finds by type" do
    tt = TransactionType.find_by_type(:debit)
    tt.id.should == TransactionType::TYPES_TO_IDS[:debit]
    tt.name.should == "DEB"
  end
  
  it "answers to is_x? appropriately" do
    transaction = TransactionType.find_by_type(:debit)
    transaction.is_debit?.should == true
    transaction.is_credit?.should == false
  end
  
end