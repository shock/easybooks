class AddPayeeSwitchToAccount < ActiveRecord::Migration
  def self.up
    add_column :accounts, :switch_target_and_description, :boolean, :default => false
  end

  def self.down
    remove_column :accounts, :switch_target_and_description
  end
end
