# A note on interest_rate:  Interest rates are stored as integers with the first two places representing fractional hundredths of a percent.  The FixedPoint class is used to abstract this internal integer storage as a fixed_point decimal number with two decimal places. in other words, an interest rate of 4.5% is stored in the database as 450.

class Account < ActiveRecord::Base
  attr_accessor :opening_balance
  
  belongs_to :institution
  has_many :base_transactions, :dependent=>:destroy
  has_many :transactions
  has_many :batch_transactions
  belongs_to :workgroup
  
  before_validation :ensure_workgroup
  validates_presence_of :workgroup, :institution, :name, :opening_date
  after_find :ensure_interest_accrual
  after_save :ensure_interest_accrual
  
  # create the opening balance transaction on create
  before_create {|record| record.opening_balance ||= FixedPoint.new(0); record.transactions << Transaction.new(:account=>record, :amount=>record.opening_balance, :transaction_type=>(record.opening_balance >= 0 ? :credit : :debit), :target=>'Opening Balance', :description=>'', :date=>record.opening_date)}
  
  INTEREST_ACCRUALS = %w{monthly annually}
  INTEREST_CONDITIONS = %w{positive_balance negative_balance both none}
  INTEREST_RATE_PRECISION = 4
  
  named_scope :by_user, lambda { |user| 
    user = User.find(user) if user.is_a? Fixnum
    {:conditions=>"accounts.workgroup_id in (#{user.workgroups.map{|w|w.id}.join(',')})"}
  }

  def validate
    errors.add(:interest_accrual, "#{interest_accrual} is invalid") unless INTEREST_ACCRUALS.include?( interest_accrual )
    errors.add(:interest_condition, "#{interest_condition} is invalid") unless INTEREST_CONDITIONS.include?( interest_condition )
  end
  
  def ensure_workgroup
    self.workgroup ||= current_user.try(:default_workgroup)
  end
  private :ensure_workgroup

  def institution
    i = Institution.find(:first, :conditions => { :id => institution_id })
  end
    
  def institution_name
    institution.name
  end

  def interest_rate= interest_rate
    @interest_rate = FixedPoint.new(interest_rate, nil, INTEREST_RATE_PRECISION)
    self[:interest_rate] = @interest_rate.value
  end
  
  def opening_balance= amount
    @opening_balance = FixedPoint.new(amount)
  end
  
  def interest_rate
    @interest_rate || FixedPoint.new(0, self[:interest_rate], INTEREST_RATE_PRECISION)
  end

  def long_name
    institution_name + ":" + name
  end
  
  def last_interest_accrual
    @last_interest_transaction ||= self.transactions.by_type(:INT).latest.first
    last_time = @last_interest_transaction ? @last_interest_transaction.date : nil
    # puts "last_time: #{last_time}"         
    last_time
  end
  
  def next_interest_accrual
    last_time = last_interest_accrual || opening_date
    
    next_time = case interest_accrual
    when 'monthly'
      last_time + 1.month
    when 'annually'
      last_time + 1.year
    end
    # puts "next_time: #{next_time}"
    next_time
  end
  
  def interest_account
    interest_condition != 'none'
  end
  
  def ensure_interest_accrual
    return unless interest_account
    while (n_i_c = next_interest_accrual) <= Date.today
      accrue_interest n_i_c
    end
  end
  
  def accrue_interest next_interest_accrual
    balance = self.balance( next_interest_accrual - 1.day )
    interest_amount = FixedPoint.new(0)
    case interest_condition
    when 'positive_balance'
      if balance > 0
        interest_amount = balance * interest_rate / 100
      end
    when 'negative_balance'
      if balance < 0
        interest_amount = balance * interest_rate / 100
      end
    when 'both'
      interest_amount = balance * interest_rate / 100
    when 'none'
      return
    end
    @last_interest_transaction = Transaction.create!(:account_id=>self.id,:date=>next_interest_accrual, :amount=>interest_amount, :transaction_type=>:INT, :target=>"Interest Charge", :description=>"Interest Accrued on $#{balance} balance.")
  end

  def balance date_or_transaction_id=nil
    if date_or_transaction_id.is_a? Date
      transactions = self.transactions.all(:conditions => "date < '#{date_or_transaction_id.to_s(:db)}'")
    elsif date_or_transaction_id.is_a? Fixnum
      transactions = self.transactions.all(:conditions => "id <= #{date_or_transaction_id.to_s}")
    else
      transactions = self.transactions.all
    end
    balance = FixedPoint.new
    transactions.each do |t|
      balance += t.amount
    end
    balance
  end

  def cleared_balance date_or_transaction_id=nil
    if date_or_transaction_id.is_a? Date
      transactions = self.transactions.registered.all(:conditions => "date <= '#{date_or_transaction_id.to_s(:db)}'")
    elsif date_or_transaction_id.is_a? Fixnum
      transactions = self.transactions.registered.all(:conditions => "id <= #{date_or_transaction_id.to_s}")
    else
      transactions = self.transactions.registered.all
    end
    balance = FixedPoint.new
    for t in transactions
      if t.registered == true
        transactions.each do |t|
          balance += t.amount
        end
      end
    end
    balance
  end
  

end
