require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe TransactionType do
  it "validates a valid record" do
    Factory(:account).valid?.should == true
  end
  
  it "validates workgroup" do
    account = Factory.build(:account, :workgroup_id=>nil)
    account.valid?.should == false
  end
  
  it "validates institution" do
    account = Factory.build(:account, :institution_id=>nil)
    account.valid?.should == false
  end
  
  it "validates name" do
    account = Factory.build(:account, :name=>nil)
    account.valid?.should == false
  end
  
  it "validates opening_date" do
    account = Factory.build(:account, :opening_date=>nil)
    account.valid?.should == false
  end
  
  it "validates interest_accrual" do
    account = Factory.build(:account, :interest_accrual=>nil)
    account.valid?.should == false
    account = Factory.build(:account, :interest_accrual=>'monthly')
    account.valid?.should == true
    account = Factory.build(:account, :interest_accrual=>'annually')
    account.valid?.should == true
  end

  it "generates long name" do
    account = Factory.build(:account)
    account.long_name.should == account.institution_name + ":" + account.name
  end
  
  it "creates an opening balance transaction" do 
    account = Factory.create(:account, :opening_balance=>12.22)
    first_transaction = account.transactions.first
    first_transaction.amount.should == 12.22
    first_transaction.transaction_type.should == :credit
    account.balance.should == 12.22
    account = Factory.create(:account, :opening_balance=>-12.22)
    first_transaction = account.transactions.first
    first_transaction.amount.should == -12.22
    first_transaction.transaction_type.should == :debit
    account.balance.should == -12.22
  end
  
  it "calculates last_interest_accrual date properly" do
    interest_accrual_date = Date.civil(2010,2,1)
    account = Factory.create(:account, :interest_accrual=>'monthly', :opening_date=>Date.civil(2010,1,1))
    transaction = Factory.create(:transaction, :account=>account, :date=>interest_accrual_date, :transaction_type=>TransactionType.interest)
    account.last_interest_accrual.should == interest_accrual_date
  end
  
  it "calculates next_interest_accrual date properly" do
    account = Factory.build(:account, :interest_accrual=>'monthly', :opening_date=>Date.civil(2010,1,1))
    account.next_interest_accrual.should == Date.civil(2010,2,1)
    account = Factory.build(:account, :interest_accrual=>'monthly', :opening_date=>Date.civil(2010,1,1))
    account.stub(:last_interest_accrual=>Date.civil(2010,2,1))
    account.next_interest_accrual.should == Date.civil(2010,3,1)
    account = Factory.build(:account, :interest_accrual=>'annually', :opening_date=>Date.civil(2010,1,1))
    account.next_interest_accrual.should == Date.civil(2011,1,1)
    account = Factory.build(:account, :interest_accrual=>'annually', :opening_date=>Date.civil(2010,1,1))
    account.stub(:last_interest_accrual=>Date.civil(2010,2,1))
    account.next_interest_accrual.should == Date.civil(2011,2,1)
    account = Factory.build(:account, :interest_accrual=>'monthly', :opening_date=>Date.civil(2010,1,1))
    account.stub(:last_interest_accrual=>Date.civil(2010,3,31))
    account.next_interest_accrual.should == Date.civil(2010,4,30)
  end
  
  it "calculates total balance correctly" do
    account = Factory(:account)
    10.times do |i|
      Factory.create(:transaction, :account=>account, :amount=>3.33, :transaction_type=>TransactionType.credit, :date=>Date.civil(2010,1,i+1))
    end
    account.balance.should == Currency.new(33.3)
  end
  
  it "calculates total balance correctly" do
    account = Factory(:account)
    10.times do |i|
      Factory.create(:transaction, :account=>account, :amount=>-3.33, :transaction_type=>TransactionType.debit, :date=>Date.civil(2010,1,i+1))
    end
    account.balance.should == Currency.new(-33.3)
  end
  
  it "calculates balance to the date" do
    start_date = Date.civil(2010,1,1)
    account = Factory(:account)
    10.times do |i|
      Factory.create(:transaction, :account=>account, :amount=>3.33, :transaction_type=>TransactionType.credit, :date=>start_date + i.days)
    end
    account.balance(start_date+5.days) == Currency.new(33.3/2)
  end
  
  it "calculates balance to the transaction" do
    start_date = Date.civil(2010,1,1)
    account = Factory(:account)
    10.times do |i|
      Factory.create(:transaction, :account=>account, :amount=>3.33, :transaction_type=>:credit, :date=>start_date + i.days)
    end
    account.balance(account.transactions.all[4]) == Currency.new(33.3/2)
  end

  it "stores interest rate with four decimal places" do
    a = Factory.build(:account)
    a.interest_rate = 4.45678
    a.save!
    a = Account.find(a.id)
    a.interest_rate.should == 4.4567
  end

  it "creates one pending interest transaction due today" do
    interest_accrual_date = Date.civil(2010,2,1)
    today = Date.civil(2010,2,1)
    Date.stub(:today).and_return(today)
    account = Factory.create(:account, :interest_accrual=>'monthly', :interest_condition=>'negative_balance', :opening_date=>Date.civil(2010,1,1), :opening_balance=>-100.0, :interest_rate=>5.0)
    account.balance.should == -105
    account.next_interest_accrual == today + 1.month
    interest_transactions = account.transactions.by_type(:interest).all
    interest_transactions.length.should == 1
    interest_transactions.first.amount.should == -5
  end
  
  it "named_scope :by_user returns all accounts accessible to the user" do 
    user = Factory(:user)
    account1 = Factory(:account)
    account2 = Factory(:account)
    account3 = Factory(:account, :workgroup=>user.default_workgroup)
    Account.by_user(user).all.should == [account3]
  end
  
  
end