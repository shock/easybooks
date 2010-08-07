class ChangeAmountToIntegerForTransaction < ActiveRecord::Migration
  def self.up
    Transaction.find_each do |t|
      t.amount *= 100
      t.save!
    end
    change_column :transactions, :amount, :integer
  end

  def self.down
    change_column :transactions, :amount, :float
    Transaction.find_each do |t|
      t.amount /= 100
      t.save!
    end
  end

end
