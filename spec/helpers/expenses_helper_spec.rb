# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExpensesHelper do
  class Klass
    include ExpensesHelper
  end

  subject(:options) { Klass.new.options_for_select(user) }

  before { create_list(:couple, rand(2..5)) }

  let(:user) { User.first }
  let(:expected_options) do
    user.couple.users.map do |user|
      [user.username, user.id]
    end
  end

  it { is_expected.to match_array(expected_options) }
end
