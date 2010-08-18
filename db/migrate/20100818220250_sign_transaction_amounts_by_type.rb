class SignTransactionAmountsByType < ActiveRecord::Migration
  def self.up
    Transaction.find_each do |t|
      t.amount = -t.amount if t.is_type_debit?
      t.save
    end
  end

  def self.down
    Transaction.find_each do |t|
      t.amount = -t.amount if t.is_type_debit?
      t.save
    end
  end
end
