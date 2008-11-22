class AddPhoneToInstitution < ActiveRecord::Migration
  def self.up
    add_column :institutions, :phone, :string
  end

  def self.down
    remove_column :institutions, :phone
  end
end
