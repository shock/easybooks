class AddWorkgroupToInstitution < ActiveRecord::Migration
  def self.up
    add_column :institutions, :workgroup_id, :integer
  end

  def self.down
    remove_column :institutions, :workgroup_id
  end
end
