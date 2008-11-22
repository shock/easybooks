class AddAccountToTransaction < ActiveRecord::Migration
  def self.up
    add_column :transactions, :account_id, :integer
  end

  def self.down
    remove_column :transactions, :account_id
  end
end
