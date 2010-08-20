class AddTypeToTransaction < ActiveRecord::Migration
  def self.up
    add_column :transactions, :type, :string
  end

  def self.down
    remove_column :transactions, :type
  end
end
