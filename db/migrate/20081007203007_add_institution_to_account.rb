class AddInstitutionToAccount < ActiveRecord::Migration
  def self.up
    add_column :accounts, :institution_id, :integer
  end

  def self.down
    remove_column :accounts, :institution_id
  end
end
