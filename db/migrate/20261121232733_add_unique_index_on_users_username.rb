# frozen_string_literal: true

# Backs the uniqueness validation on User#username with a database-level
# constraint, as required by Rails/UniqueValidationWithoutIndex.
class AddUniqueIndexOnUsersUsername < ActiveRecord::Migration[8.1]
  def change
    add_index :users, :username, unique: true
  end
end
