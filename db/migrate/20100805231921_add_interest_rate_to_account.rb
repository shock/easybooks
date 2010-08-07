class AddInterestRateToAccount < ActiveRecord::Migration
  def self.up
    add_column :accounts, :annual_interest_rate, :float, :default=>0.0
    add_column :accounts, :interest_accrual, :string, :default=>'annually'
    add_column :accounts, :interest_condition, :string, :default=>'none'
  end

  def self.down
    remove_column :accounts, :interest_condition
    remove_column :accounts, :interest_accrual
    remove_column :accounts, :annual_interest_rate
  end
end
