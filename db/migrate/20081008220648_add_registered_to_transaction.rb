class AddRegisteredToTransaction < ActiveRecord::Migration
  def self.up
    add_column :transactions, :registered, :boolean, :null => false
  end

  def self.down
    remove_column :transactions, :registered
  end
end
