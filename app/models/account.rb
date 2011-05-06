# A note on interest_rate:  Interest rates are stored as integers with the first two places representing fractional hundredths of a percent.  The FixedPoint class is used to abstract this internal integer storage as a fixed_point decimal number with two decimal places. in other words, an interest rate of 4.5% is stored in the database as 450.

class Account < ActiveRecord::Base
  attr_accessor :opening_balance
  
  belongs_to :institution
  has_many :base_transactions, :dependent=>:destroy
  has_many :transactions, :order=>:date
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

  # Returns the account balance just prior to the transaction specified by the argument.
  # If the argument is a date, then the balance is the closing balance of the previous date.
  # If the argument is a transaction ID, then the the balance is the balance prior to that transaction.
  def balance date_or_transaction_id=nil
    if date_or_transaction_id.is_a? Date
      transactions = self.transactions.all(:conditions => "date < '#{date_or_transaction_id.to_s(:db)}'")
    elsif date_or_transaction_id.is_a? Fixnum
      transactions = self.transactions.all(:conditions => "id < #{date_or_transaction_id}")
    else
      transactions = self.transactions.all
    end
    FixedPoint.new(transactions.map(&:amount).sum)
  end

  # Same as the method :balance, but only considers registered transactions
  def cleared_balance date_or_transaction_id=nil
    if date_or_transaction_id.is_a? Date
      transactions = self.transactions.registered.all(:conditions => "date < '#{date_or_transaction_id.to_s(:db)}'")
    elsif date_or_transaction_id.is_a? Fixnum
      transactions = self.transactions.registered.all(:conditions => "id < #{date_or_transaction_id.to_s}")
    else
      transactions = self.transactions.registered.all
    end
    FixedPoint.new(transactions.map(&:amount).sum)
  end
  
  def process_import_transactions import_transactions
    import_transactions.each do |new_transaction|
      if self.switch_target_and_description?
        tmp = new_transaction.target
        new_transaction.target = new_transaction.description
        new_transaction.description = tmp
      end
      if existing_transaction = self.transactions.find_by_transaction_id( new_transaction.transaction_id )
        if existing_transaction.amount == new_transaction.amount
          # we already have this transaction.
        else
          # we have this transaction with a different amount.  we'll leave it
          # and make sure it isn't marked as registered
          existing_transaction.clear_registered
          # plus we'll add the one from the bank
          transactions << new_transaction
        end
      elsif !new_transaction.check_num.blank? && (existing_transaction = self.transactions.find_by_check_num( new_transaction.check_num ))
        if existing_transaction.amount == new_transaction.amount
          # we already have this transaction.  set it's transaction id and mark it as registered
          existing_transaction.transaction_id = new_transaction.transaction_id
          existing_transaction.registered = true
          existing_transaction.save!
        else
          # we have this transaction with a different amount.  we'll leave it
          # and make sure it isn't marked as registered
          existing_transaction.clear_registered
          # plus we'll add the one from the bank
          transactions << new_transaction
        end
      else
        # this is a new transaction without an existing transaction id or check #
        # we'll add it to the account as unregistered
        self.transactions << new_transaction
      end 
    end
  end

  DEDUP_TIME_TOLERANCE_DAYS = 5
  def find_next_potential_duplicate_transactions( duplicate_proximity_tolerance = DEDUP_TIME_TOLERANCE_DAYS )
    account = self
    transactions = account.transactions.all
    amount_groups = transactions.group_by{|t|t.amount.value}
    amount_groups.each do |amount, transactions|
      transactions.sort!{|a,b| a.date <=> b.date}
      next if transactions.length < 2
      # puts amount.inspect
      # puts transactions.inspect
      transactions.each_with_index do |t1,i|
        break if t1 == transactions.last
        t2 = transactions[i+1]
        next if !(t1.transaction_id.blank? || t2.transaction_id.blank?)
        time_diff = t2.date - t1.date
        # puts time_diff
        next if time_diff > duplicate_proximity_tolerance
        [t1,t2].each do |transaction, i|
          puts "T#{i}: #{transaction.date.strftime("%D")} - #{transaction.amount} - #{transaction.target} - #{transaction.description} - #{transaction.transaction_id}"
        end
        puts "--"
      end
    end
    nil
  end

  def duplicate_transactions( duplicate_proximity_tolerance = DEDUP_TIME_TOLERANCE_DAYS )
    account = self
    transactions = account.transactions.all
    amount_groups = transactions.group_by{|t|t.amount.value}
    dup_counts = 0
    amount_groups.each do |amount, transactions|
      transactions.sort!{|a,b| a.date <=> b.date}
      next if transactions.length < 2
      # puts amount.inspect
      # puts transactions.inspect
      transactions.each_with_index do |t1,i|
        break if t1 == transactions.last
        t2 = transactions[i+1]
        next if !(t1.transaction_id.blank? || t2.transaction_id.blank?)
        # next if t1.registered? && t2.registered?
        time_diff = t2.date - t1.date
        # puts time_diff
        next if time_diff > duplicate_proximity_tolerance
        yield( t1, t2 ) if block_given?
        dup_counts += 1
      end
    end
    dup_counts
  end
  
  def show_duplicate_transactions( duplicate_proximity_tolerance = DEDUP_TIME_TOLERANCE_DAYS )
    duplicate_transactions( duplicate_proximity_tolerance ) do |t1, t2|
      [t1,t2].each do |transaction, i|
        puts "T#{i}: #{transaction.date.strftime("%D")} - #{transaction.amount} - [#{transaction.registered? ? "X" : " "}] - #{transaction.target} - #{transaction.description} - #{transaction.transaction_id}"
      end
      puts "--"
    end
    nil
  end
  
  def format_transaction( transaction )
    "#{transaction.date.strftime("%D")} - [#{transaction.registered? ? "X" : " "}] : #{transaction.amount} - #{transaction.target} - #{transaction.description} - #{transaction.transaction_id}"
  end
  
  def get_answer( question, answers )
    answer = ""
    defaults = answers.reject{|a| a.upcase.first != a.first || a.upcase.first =~ /\d/}
    raise "Too many default answers: #{answers.inspect}" if defaults.length > 1
    default = defaults.first
    puts "default: #{default}"
    normalized_answers = answers.map{|a| a.downcase}
    while !normalized_answers.include?(answer)
      print "#{question} [#{answers.join("/")}] "
      $stdout.flush
      answer = gets.chomp.downcase.first
      puts "answer: #{answer}"
      return default.downcase if default && answer.blank?
    end
    answer
  end

  def merge_duplicate_transactions( duplicate_proximity_tolerance = DEDUP_TIME_TOLERANCE_DAYS )
    merged_count = 0
    dup_counts = duplicate_transactions( duplicate_proximity_tolerance ) do |t1, t2|
      [t1,t2].each_with_index do |transaction, i|
        puts "T#{i+1}: #{format_transaction( transaction )}"
      end
      answer = get_answer("Merge transactions?", ["Y","n"])
      if answer=="y"
        answer = get_answer("Keep which description?", ["1","2"])
        case answer
        when "1"
          base = t1
          extra = t2
        when "2"
          base = t2
          extra = t1
        end
        transaction_id = [t1,t2].map{|t| t.transaction_id}.reject(&:blank?).first
        base.transaction_id = transaction_id
        puts "Merged transaction:"
        puts format_transaction( base )
        answer = get_answer("Commit?", ["Y","n"])
        if answer == "y"
          unless base.registered?
            answer = get_answer("Clear merged transaction?", ["Y","n"])
            base.registered = (answer == "y")
          end
          merged_count += 1
          extra.destroy
          base.save!
        else
          puts "Skipping..."
        end
      else
        puts "Skipping..."
      end
      puts "--"
    end
    if dup_counts > 0
      puts "#{merged_count} transactions merged."
      puts "#{dup_counts - merged_count} transactions skipped."
    else
      puts "No duplicates found."
    end
    nil
  end

  def clear_transactions
    answer = get_answer("Merge duplicates first?", ["Y", "n"])
    merge_duplicate_transactions if answer == "y"
    transactions.registered(false).find_each do |transaction|
      puts format_transaction( transaction )
      answer = get_answer("Clear transaction (x aborts)?", %w(Y n x))
      case answer
      when "y"
        transaction.update_attribute(:registered, true) 
        puts "Transaction cleared."
      when "n" 
        puts "Skipped transaction."
      when "x"
        puts "Aborting."
        break
      end
    end
  end
  
  def clear_all_transactions
    answer = get_answer("Merge duplicates first?", ["Y", "n"])
    merge_duplicate_transactions if answer == "y"
    count = transactions.registered(false).count
    puts "#{count} un-cleared transactions."
    return unless count > 0
    answer = get_answer("Clear All Transactions?", ["y", "N"])
    if answer == "y"
      transactions.update_all(:registered=>true) 
      puts "All transactions cleared."
    else
      puts "No transactions changed."
    end
  end
  
  alias :merge_transactions :merge_duplicate_transactions
  
  def create_transaction
    print "Enter target: "
    $stdout.flush
    target = gets.chomp
    print "Enter description: "
    $stdout.flush
    description = gets.chomp
    print "Enter date: "
    $stdout.flush
    date = Date.parse(gets.chomp)
    date = Date.civil(date.year + 2000, date.month, date.day) if date.year < 2000
    print "Enter amount: "
    $stdout.flush
    amount = gets.chomp
    transaction = Transaction.new(:target=>target, :date=>date, :amount=>amount, :description=>description)
    if transaction.amount < 0
      transaction.transaction_type = :DEBIT
    else
      transaction.transaction_type = :CREDIT
    end
    puts format_transaction( transaction )
    answer = get_answer("Commit Transaction?", ["Y", "n"])
    if answer == "y"
      transactions << transaction 
      puts "Transaction committed."
    else
      puts "Transaction aborted."
    end
  end
  
end
