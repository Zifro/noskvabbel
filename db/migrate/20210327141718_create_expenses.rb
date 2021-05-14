# frozen_string_literal: true

class CreateExpenses < ActiveRecord::Migration[6.1]
  def change
    create_table :expenses do |t|
      t.references :user
      t.decimal :amount, precision: 5, scale: 2
      t.string :label
      t.date :spent_on
      t.integer :created_by_id
      t.timestamps
    end

    add_index(:expenses, %i[amount label spent_on], unique: true)
  end
end
