class AddTransactionTypeToTransaction < ActiveRecord::Migration
  def self.up
    add_column :transactions, :transaction_type_id, :integer
  end

  def self.down
    remove_column :transactions, :transaction_type_id
  end
end
