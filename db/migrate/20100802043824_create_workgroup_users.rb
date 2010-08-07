class CreateWorkgroupUsers < ActiveRecord::Migration
  def self.up
    create_table :workgroups_users do |t|
      t.integer :workgroup_id
      t.integer :user_id

      t.timestamps
    end
  end

  def self.down
    drop_table :workgroups_users
  end
end
