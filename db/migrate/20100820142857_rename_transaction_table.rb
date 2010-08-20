class RenameTransactionTable < ActiveRecord::Migration
  def self.up
    rename_table :transactions, :base_transactions
  end

  def self.down
    rename_table :base_transactions, :transactions
  end
end
