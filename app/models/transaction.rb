class Transaction < ActiveRecord::Base
  belongs_to :account
  belongs_to :category
  belongs_to :transaction_type

  validates_presence_of :name, :amount, :account_id, :date

  def category
    c = Category.find(:first, :conditions => { :id => category_id })
  end

  def type
    t = TransactionType.find(:first, :conditions => { :id => transaction_type_id })
  end

  def account
    a = Account.find(:first, :conditions => { :id => account_id })
  end

end
