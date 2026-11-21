# frozen_string_literal: true

# Speeds up the date-window queries used by the lazy loading on expenses#index.
# (index_expenses_on_user_id already exists for the per-user totals.)
class AddIndexOnExpensesSpentOn < ActiveRecord::Migration[8.1]
  def change
    add_index :expenses, :spent_on
  end
end
