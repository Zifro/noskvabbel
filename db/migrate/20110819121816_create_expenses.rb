class CreateExpenses < ActiveRecord::Migration
  def self.up
    create_table :expenses do |t|
      t.integer :user_id
      t.decimal :amount
      t.string :label
      t.date :spent_on
      t.timestamps
    end
  end

  def self.down
    drop_table :expenses
  end
end
