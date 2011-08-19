class CreateCouples < ActiveRecord::Migration
  def self.up
    create_table :couples do |t|
      t.timestamps
    end
  end

  def self.down
    drop_table :couples
  end
end
