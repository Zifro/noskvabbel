# frozen_string_literal: true

require 'rails_helper'

ALPHABET_WITHOUT_M_AND_F = (('A'..'Z').to_a - %w[M F]).freeze

describe User do
  subject(:user) { create(:user) }

  let(:another_user) { create(:user) }

  describe 'attributes' do
    let(:user) { described_class.new }

    it { expect(user.attributes).to have_key('username') }
    it { is_expected.to respond_to(:username) }
    it { is_expected.to respond_to(:username=) }

    it { expect(user.attributes).to have_key('email') }
    it { is_expected.to respond_to(:email) }
    it { is_expected.to respond_to(:email=) }

    it { is_expected.to respond_to(:password=) }

    it { expect(user.attributes).to have_key('gender') }
    it { is_expected.to respond_to(:gender) }
    it { is_expected.to respond_to(:gender=) }

    it { expect(user.attributes).to have_key('expenses_total') }
    it { is_expected.to respond_to(:expenses_total) }
    it { is_expected.to respond_to(:expenses_total=) }
  end

  describe 'associations' do
    describe 'couple' do
      subject(:user) { create(:user, :in_couple) }

      it { is_expected.to respond_to(:couple) }
      it { expect(user.couple.users).to include(user) }
    end

    describe 'expenses' do
      subject(:user) { create(:user, :with_expenses) }

      it { is_expected.to respond_to(:expenses) }
      it { expect(user.expenses.first).to be_an(Expense) }
    end
  end

  describe 'expenses_total' do
    it 'defaults to 0' do
      expect(described_class.new.expenses_total).to eq(0)
    end

    describe '#update_expenses_total!' do
      subject(:user) { create(:user, :with_expenses) }

      before { user.update!(expenses_total: 0) }

      it 'recalculates and persists the sum of the expenses of the user' do
        expect { user.update_expenses_total! }
          .to change { user.reload.expenses_total }
          .from(0).to(user.expenses.sum(:amount))
      end

      it 'persists 0 when the user has no expenses' do
        user.expenses.destroy_all
        user.update_expenses_total!
        expect(user.reload.expenses_total).to eq(0)
      end

      it 'persists the total without running validations (derived cache column)' do
        user.expenses.destroy_all
        user.username = nil # invalid in memory: must not prevent the cache update

        expect { user.update_expenses_total! }.not_to raise_error
        expect(user.reload.expenses_total).to eq(0)
      end
    end
  end

  describe 'validations' do
    context 'when username is already taken with a different case' do
      before { user.username = another_user.username.upcase }

      it { is_expected.not_to be_valid }
    end

    context 'when gender is not set' do
      before { user.gender = nil }

      it { is_expected.to be_valid }
    end

    context 'when gender is set to M' do
      before { user.gender = 'M' }

      it { is_expected.to be_valid }
    end

    context 'when gender is set to F' do
      before { user.gender = 'F' }

      it { is_expected.to be_valid }
    end

    context 'when gender is set to another letter' do
      let(:a_capital_letter_other_than_m_or_f) { ALPHABET_WITHOUT_M_AND_F.sample }

      before { user.gender = a_capital_letter_other_than_m_or_f }

      it { is_expected.not_to be_valid }
      it { expect(user.errors[:gender]).to be_empty }
    end
  end
end
