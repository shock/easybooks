class CreateWorkgroups < ActiveRecord::Migration
  def self.up
    create_table :workgroups do |t|
      t.string :name

      t.timestamps
    end
  end

  def self.down
    drop_table :workgroups
  end
end
