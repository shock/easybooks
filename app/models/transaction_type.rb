class TransactionType < ActiveRecord::Base
  has_many :transactions
end
