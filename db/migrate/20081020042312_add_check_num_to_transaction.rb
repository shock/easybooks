class AddCheckNumToTransaction < ActiveRecord::Migration
  def self.up
    add_column :transactions, :check_num, :string
  end

  def self.down
    remove_column :transactions, :check_num
  end
end
