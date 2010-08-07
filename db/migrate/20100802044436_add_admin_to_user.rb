class AddAdminToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :admin_flag, :boolean
  end

  def self.down
    remove_column :users, :admin_flag
  end
end
