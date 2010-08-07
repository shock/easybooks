class ChangeNameToTargetForTranscation < ActiveRecord::Migration
  def self.up
    rename_column :transactions, :name, :target
  end

  def self.down
    rename_column :transactions, :target, :name
  end
end
