# frozen_string_literal: true

class Expense < ApplicationRecord
  default_scope { order('spent_on DESC, id desc') }

  belongs_to :user
  belongs_to :created_by, class_name: 'User'

  validates :user, :created_by, :label, :spent_on, presence: true
  validates :amount, presence: true,
                     numericality: { greater_than_or_equal_to: 0.01 },
                     uniqueness: { scope: %i[label spent_on], message: 'This expense has already been recorded' }

  after_destroy :sync_users_expenses_total
  after_save :sync_users_expenses_total

  def spent_on
    attributes['spent_on'] ||= Time.zone.today
  end

private

  # Keeps the cached expenses_total of the affected users in sync
  def sync_users_expenses_total
    affected_users = [user]
    previous_user_id = saved_changes['user_id']&.first
    affected_users << User.find(previous_user_id) if previous_user_id
    affected_users.compact.uniq.each(&:update_expenses_total!)
  end
end
