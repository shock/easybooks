class AddWorkgroupToAccount < ActiveRecord::Migration
  def self.up
    add_column :accounts, :workgroup_id, :integer
  end

  def self.down
    remove_column :accounts, :workgroup_id
  end
end
