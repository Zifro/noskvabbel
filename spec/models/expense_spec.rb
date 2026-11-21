# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Expense do
  subject(:expense) { create(:expense) }

  describe 'attributes' do
    subject(:expense) { described_class.new }

    it { expect(expense.attributes).to have_key('amount') }
    it { is_expected.to respond_to(:amount) }
    it { is_expected.to respond_to(:amount=) }

    it { expect(expense.attributes).to have_key('label') }
    it { is_expected.to respond_to(:label) }
    it { is_expected.to respond_to(:label=) }

    it { expect(expense.attributes).to have_key('spent_on') }
    it { is_expected.to respond_to(:spent_on) }
    it { is_expected.to respond_to(:spent_on=) }
  end

  describe 'associations' do
    it { is_expected.to respond_to(:user) }
    it { is_expected.to respond_to(:user=) }

    it { is_expected.to respond_to(:created_by) }
    it { is_expected.to respond_to(:created_by=) }
  end

  describe 'validations' do
    context 'without an amount' do
      before { expense.amount = nil }

      it { is_expected.not_to be_valid }
    end

    context 'with an amount of 0' do
      before { expense.amount = 0 }

      it { is_expected.not_to be_valid }
    end

    context 'with a non-numerical amount' do
      before { expense.amount = Faker::Lorem.word }

      it { is_expected.not_to be_valid }
    end

    context 'without a label' do
      before { expense.label = nil }

      it { is_expected.not_to be_valid }
    end

    context 'without a spent_on information' do
      before { expense.spent_on = nil }

      it { is_expected.to be_valid }
      it { expect(expense.spent_on).to eq(Time.zone.today) }
    end

    context 'without a user' do
      before { expense.user = nil }

      it { is_expected.not_to be_valid }
    end

    context 'without a created_by' do
      before { expense.created_by = nil }

      it { is_expected.not_to be_valid }
    end

    context 'with the same name, amount, and date than another expense' do
      let(:doppelganger) do
        build(
          :expense,
          amount: expense.amount,
          label: expense.label,
          spent_on: expense.spent_on
        )
      end

      before { doppelganger.valid? }

      it { expect(doppelganger).not_to be_valid }
      it { expect(doppelganger.errors[:amount]).to match_array('This expense has already been recorded') }
    end
  end

  describe 'expenses_total synchronization' do
    let(:user) { create(:user) }
    let(:other_user) { create(:user) }

    it 'sets the expenses_total of the user when an expense is created' do
      create(:expense, user: user, created_by: user, amount: 12.34)

      expect(user.reload.expenses_total).to eq(12.34)
    end

    it 'sums all the expenses of the user' do
      create(:expense, user: user, created_by: user, amount: 10)
      create(:expense, user: user, created_by: user, amount: 2.5)

      expect(user.reload.expenses_total).to eq(12.5)
    end

    it 'updates the expenses_total of the user when the amount is updated' do
      expense = create(:expense, user: user, created_by: user, amount: 10)

      expense.update!(amount: 25.5)

      expect(user.reload.expenses_total).to eq(25.5)
    end

    it 'updates the expenses_total of both users when the expense is moved to another user' do
      expense = create(:expense, user: user, created_by: user, amount: 10)

      expense.update!(user: other_user)

      expect(user.reload.expenses_total).to eq(0)
      expect(other_user.reload.expenses_total).to eq(10)
    end

    it 'updates the expenses_total of the user when the expense is destroyed' do
      expense = create(:expense, user: user, created_by: user, amount: 10)

      expense.destroy

      expect(user.reload.expenses_total).to eq(0)
    end
  end
end
