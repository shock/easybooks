class AddAccountNumberToAccount < ActiveRecord::Migration
  def self.up
    add_column :accounts, :account_number, :string
  end

  def self.down
    remove_column :accounts, :account_number
  end
end
