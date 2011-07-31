require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Transaction do
  it "stores amounts with cents as integer" do
    t = Factory.build(:transaction)
    t.amount = 10.33
    t.save!
    t = Transaction.find(t.id)
    t.amount.should == 10.33
  end

  it "stores amounts with two decimal places" do
    t = Factory.build(:transaction)
    t.amount = 10.339
    t.save!
    t = Transaction.find(t.id)
    t.amount.should == 10.33
  end

  it "sets the transaction type by symbol" do
    transaction = Factory.build(:transaction)
    transaction.transaction_type = :INT
    transaction.transaction_type_id.should == TransactionType::TYPES_TO_IDS[:INT]
  end

  it "named_scope by_type retuns the correct results" do
    start_date = Date.today
    Transaction.count.should == 0
    Factory.create(:transaction, :transaction_type=>:INT)
    Factory.create(:transaction, :transaction_type=>:CREDIT)
    Transaction.by_type(:INT).count.should == 1
    Transaction.by_type(:DEBIT).count.should == 0
    Transaction.by_type(:CREDIT).count.should == 3 # because the account creates an opening balance transaction
  end

  it "answers to is_type_x? appropriately" do
    transaction = Factory.build(:transaction, :transaction_type=>:INT)
    transaction.is_type_int.should == true
  end
end