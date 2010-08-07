class AddLastInterestAccrualToAccount < ActiveRecord::Migration
  def self.up
    add_column :accounts, :last_interest_accrual, :date
  end

  def self.down
    remove_column :accounts, :last_interest_accrual
  end
end
