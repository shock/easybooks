class UniqueTransactionIndex < ActiveRecord::Migration
  def self.up
    add_index :transactions, [:account_id, :transaction_id], :unique=>true, :name=>:aid_tid
  end

  def self.down
    remove_index :transactions, :name=>:aid_tid
  end
end
