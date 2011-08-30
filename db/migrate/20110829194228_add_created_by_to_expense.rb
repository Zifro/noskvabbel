class AddCreatedByToExpense < ActiveRecord::Migration
  def self.up
    add_column :expenses, :created_by_id, :integer
  end

  def self.down
    remove_column :users, :created_by_id
  end
end
