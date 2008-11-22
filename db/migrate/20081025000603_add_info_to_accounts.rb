class AddInfoToAccounts < ActiveRecord::Migration
  def self.up
    add_column :accounts, :info, :string
    add_column :accounts, :phone, :string
  end

  def self.down
    remove_column :accounts, :phone
    remove_column :accounts, :info
  end
end
