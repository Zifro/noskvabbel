# frozen_string_literal: true

class Couple < ApplicationRecord
  has_many :users, dependent: :restrict_with_exception
  has_many :expenses, through: :users

  validate :there_are_two_users

private

  def there_are_two_users
    errors.add(:users, 'there must be two users (lovers) in a couple') unless users.length == 2
  end
end
