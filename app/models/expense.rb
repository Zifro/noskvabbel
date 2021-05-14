# frozen_string_literal: true

class Expense < ApplicationRecord
  default_scope { order('spent_on DESC, id desc') }

  belongs_to :user
  belongs_to :created_by, class_name: 'User'

  validates :user, :created_by, :label, :spent_on, presence: true
  validates :amount, presence: true,
                     numericality: { greater_than_or_equal_to: 0.01 },
                     uniqueness: { scope: %i[label spent_on], message: 'This expense has already been recorded' }

  def spent_on
    attributes['spent_on'] ||= Time.zone.today
  end
end
