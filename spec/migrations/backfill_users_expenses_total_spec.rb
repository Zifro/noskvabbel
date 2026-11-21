# frozen_string_literal: true

require 'rails_helper'
require Rails.root.join('db', 'migrate', '20261121105100_backfill_users_expenses_total')

RSpec.describe BackfillUsersExpensesTotal do
  # Simulates users whose expenses were recorded before the expenses_total
  # column existed, by resetting the cache to a wrong value
  def reset_expenses_total_cache
    User.find_each { |user| user.update!(expenses_total: 0) }
  end

  it 'initializes expenses_total from the existing expenses of each user' do
    user = create(:user)
    other_user = create(:user)
    create(:expense, user: user, created_by: user, amount: 10.50)
    create(:expense, user: user, created_by: user, amount: 2.25)
    create(:expense, user: other_user, created_by: other_user, amount: 99.99)
    reset_expenses_total_cache

    described_class.new.up

    expect(user.reload.expenses_total).to eq(12.75)
    expect(other_user.reload.expenses_total).to eq(99.99)
  end

  it 'sets expenses_total to 0 for users without any expense' do
    user = create(:user)
    user.update!(expenses_total: 42)

    described_class.new.up

    expect(user.reload.expenses_total).to eq(0)
  end
end
