# frozen_string_literal: true

class CreateUserSessions < ActiveRecord::Migration[6.1]
  def change
    create_table :user_sessions do |t|
      t.string :username
      t.string :password
      t.timestamps
    end
  end
end
