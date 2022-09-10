# frozen_string_literal: true

class Couple < ApplicationRecord
  has_many :users, dependent: :restrict_with_exception
  has_many :expenses, through: :users

  validate :there_are_zero_or_two_users

private

  def there_are_zero_or_two_users
    count = users.count
    unless count == 0 || count == 2
      errors.add(:users, 'there must be zero of two users (lovers) in a couple')
    end
  end
end
