# frozen_string_literal: true

# Populates the new expenses_total cache for users who already have expenses,
# so that the column is initialized from the current balances.
class BackfillUsersExpensesTotal < ActiveRecord::Migration[8.1]
  def up
    execute <<~SQL.squish
      UPDATE users
      SET expenses_total = COALESCE(
        (SELECT SUM(expenses.amount) FROM expenses WHERE expenses.user_id = users.id),
        0
      )
    SQL
  end

  def down; end
end
