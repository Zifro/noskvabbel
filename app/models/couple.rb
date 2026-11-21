# frozen_string_literal: true

class Couple < ApplicationRecord
  has_many :users, dependent: :restrict_with_exception
  has_many :expenses, through: :users

  validate :there_are_zero_or_two_users

private

  def there_are_zero_or_two_users
    count = users.count
    return if [0, 2].include?(count)

    errors.add(:users, 'there must be zero of two users (lovers) in a couple')
  end
end
