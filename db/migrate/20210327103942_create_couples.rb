# frozen_string_literal: true

class CreateCouples < ActiveRecord::Migration[6.1]
  def change
    create_table :couples, &:timestamps
  end
end
