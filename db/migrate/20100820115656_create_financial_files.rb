class CreateFinancialFiles < ActiveRecord::Migration
  def self.up
    create_table :financial_files do |t|
      t.string :filename
      t.datetime :filedate
      t.string :type

      t.timestamps
    end
  end

  def self.down
    drop_table :financial_files
  end
end
