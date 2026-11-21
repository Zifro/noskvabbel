# frozen_string_literal: true

class AddExpensesTotalToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :expenses_total, :decimal, precision: 10, scale: 2, default: 0.0
  end
end
