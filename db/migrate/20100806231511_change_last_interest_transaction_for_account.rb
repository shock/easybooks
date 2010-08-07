class ChangeLastInterestTransactionForAccount < ActiveRecord::Migration
  def self.up
    remove_column :accounts, :last_interest_accrual
    change_column :accounts, :annual_interest_rate, :integer
    rename_column :accounts, :annual_interest_rate, :interest_rate
  end

  def self.down
    add_column :accounts, :last_interest_accrual, :date
    rename_column :accounts, :interest_rate, :annual_interest_rate
    change_column :accounts, :annual_interest_rate, :float
  end
end
