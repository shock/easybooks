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

  it "named_scope latest retuns the most recent transaction" do
    start_date = Date.today
    transactions = []
    10.times do |i|
      transactions << Factory.create(:transaction, :date=>start_date + i.days)
    end
    Transaction.latest.first.should == transactions.last
  end
  
  it "sets the transaction type by symbol" do
    transaction = Factory.build(:transaction)
    transaction.transaction_type = :interest
    transaction.transaction_type_id.should == TransactionType::TYPES_TO_IDS[:interest]
  end

  it "named_scope by_type retuns the correct results" do
    start_date = Date.today
    Transaction.count.should == 0
    Factory.create(:transaction, :transaction_type=>:interest)
    Factory.create(:transaction, :transaction_type=>:credit)
    Transaction.by_type(:interest).count.should == 1
    Transaction.by_type(:credit).count.should == 1
    Transaction.by_type(:debit).count.should == 0
  end
end