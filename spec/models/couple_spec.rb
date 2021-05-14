# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Couple do
  let(:couple) { create(:couple) }

  describe 'associations' do
    it { expect(couple).to respond_to(:users) }
    it { expect(couple).to respond_to(:expenses) }
  end

  describe 'validations' do
    context 'without users' do
      before { couple.users = [] }

      it { expect(couple).not_to be_valid }
    end

    context 'with only one user' do
      let(:user) { create(:user) }

      before { couple.users = [user] }

      it { expect(couple).not_to be_valid }
    end

    context 'with two users' do
      it { expect(couple.users).to have(2).items }
      it { expect(couple).to be_valid }
    end

    context 'with more than two users' do
      let(:number_of_users) { rand(3..10) }

      before { couple.users = create_list(:user, number_of_users) }

      it { expect(couple).not_to be_valid }
    end
  end
end
