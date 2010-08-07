class AddLinkedAccountToTransaction < ActiveRecord::Migration
  def self.up
    add_column :transactions, :linked_account_id, :integer
  end

  def self.down
    remove_column :transactions, :linked_account_id
  end
end
