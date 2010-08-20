# A note on transaction amounts:  Transaction amounts are stored as integers with the first two places representing cents.  The Currency class is used to abstract this internal integer storage as a fixed_point decimal number with two decimal places. in other words, an transaction amount of $12.38 is stored in the database as 1238.

require 'lib/extensions/currency'

class Transaction < ActiveRecord::Base
  belongs_to :account
  belongs_to :category

  before_validation :before_validation_callback
  validates_presence_of :amount, :account, :date, :transaction_type_id
  
  def transaction_type
    @transaction_type = TransactionType.find(transaction_type_id)
  end
  
  default_scope :order=>"date ASC, amount"
  
  named_scope :registered, lambda { |*args| 
    if( args[0] )
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

  named_scope :latest, {:order=>'date DESC', :limit=>1} 

  
  def transaction_type= transaction_type
    transaction_type = TransactionType.send(transaction_type) if transaction_type.is_a? Symbol
    return "Invalid transaction type" unless transaction_type && transaction_type.is_a?( TransactionType ) && transaction_type.valid?
    @transaction_type = transaction_type
    self.transaction_type_id = transaction_type.id
  end
  
  def amount= amount
    @amount = Currency.new(amount)
    self[:amount] = @amount.value
  end
  
  def amount
    @amount || Currency.new(0, self[:amount])
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
