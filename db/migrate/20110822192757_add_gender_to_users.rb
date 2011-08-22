class AddGenderToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :gender, :string, :limit => 1
  end

  def self.down
    remove_column :users, :gender
  end
end
