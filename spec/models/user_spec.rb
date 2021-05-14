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

  describe 'validations' do
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
