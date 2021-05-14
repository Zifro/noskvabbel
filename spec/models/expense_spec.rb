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

    context 'with an amount lower than 0.01' do
      before { expense.amount = Faker::Number.between(from: 0.001, to: 0.009) }

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
end
