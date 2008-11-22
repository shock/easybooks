class CreateTransactions < ActiveRecord::Migration
  def self.up
    create_table :transactions do |t|
      t.string :name
      t.string :description
      t.float :amount
      t.date :date

      t.timestamps
    end
  end

  def self.down
    drop_table :transactions
  end
end
