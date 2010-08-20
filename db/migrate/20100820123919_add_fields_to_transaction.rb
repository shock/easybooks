class AddFieldsToTransaction < ActiveRecord::Migration
  def self.up
    add_column :transactions, :linked_transaction_id, :integer
    add_column :transactions, :transaction_id, :string
  end

  def self.down
    remove_column :transactions, :transaction_id
    remove_column :transactions, :linked_transaction_id
  end
end
