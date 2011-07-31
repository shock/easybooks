# A note on transaction amounts:  Transaction amounts are stored as integers with the first two places representing cents.  The FixedPoint class is used to abstract this internal integer storage as a fixed_point decimal number with two decimal places. in other words, an transaction amount of $12.38 is stored in the database as 1238.

class Transaction < ActiveRecord::Base
  belongs_to :account
  belongs_to :category
  cattr_accessor :per_page
  self.per_page = 10

  before_validation :before_validation_callback
  validates_presence_of :amount, :account, :date, :transaction_type_id

  def transaction_type
    @transaction_type = TransactionType.find(transaction_type_id)
  end


  named_scope :registered, lambda { |*args|
    if( args.length > 0 )
      {:conditions=>{:registered=>args[0]}}
    else
      {:conditions=>{:registered=>true}}
    end
  }

  named_scope :by_type, lambda { |*args|
    if( type = args[0] )
      type = TransactionType.send(type) if type.is_a? Symbol
      raise "Unknown Transaction Type #{type.inspect}" unless type.is_a? TransactionType
      {:conditions=>{:transaction_type_id=>type.id}}
    else
      raise "You must specify a type."
    end
  }

  named_scope :sorted, lambda { |*args|
    if( args[0] )
      {:order=>args[0]}
    else
      {:order=>'date'}
    end
  }

  def transaction_type= transaction_type
    transaction_type = TransactionType.send(transaction_type) if transaction_type.is_a? Symbol
    return "Invalid transaction type" unless transaction_type && transaction_type.is_a?( TransactionType ) && transaction_type.valid?
    @transaction_type = transaction_type
    self.transaction_type_id = transaction_type.id
  end

  def amount= amount
    @amount = FixedPoint.new(amount)
    self[:amount] = @amount.value
  end

  def amount
    @amount || FixedPoint.new(0, self[:amount])
  end

  def set_registered
    update_attribute(:registered,true)
  end

  def clear_registered
    update_attribute(:registered,false)
  end

  private
    def before_validation_callback
      self.registered = false if self.registered.nil?
      if self.transaction_type
        if self.transaction_type.valid?
          self.transaction_type_id = self.transaction_type.id
        else
          errors.add(:transaction_type_id, "Invalid transaction type")
        end
      end
    end

    def method_missing method, *args
      if matches = method.to_s.match( /is_type_(\w*)?/ )
        eval "self.transaction_type.is_#{matches[1]}?"
      else
        super
      end
    end


end
