class AddWorkgroupToCategory < ActiveRecord::Migration
  def self.up
    add_column :categories, :workgroup_id, :integer
  end

  def self.down
    remove_column :categories, :workgroup_id
  end
end
