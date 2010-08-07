class AddOpeningDateToAccount < ActiveRecord::Migration
  def self.up
    add_column :accounts, :opening_date, :date
  end

  def self.down
    remove_column :accounts, :opening_date
  end
end
