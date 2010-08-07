class AddDefaultWorkgroupToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :default_workgroup_id, :integer
  end

  def self.down
    remove_column :users, :default_workgroup_id
  end
end
