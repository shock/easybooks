class AddTypeToTransaction < ActiveRecord::Migration
  def self.up
    add_column :transactions, :type, :string
    Transaction.connection.execute("update transactions set type='Transaction'")
  end

  def self.down
    remove_column :transactions, :type
  end
end
