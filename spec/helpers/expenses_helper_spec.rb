# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExpensesHelper do
  subject(:options) { klass.new.options_for_select(user) }

  let(:klass) { Class.new { include ExpensesHelper } }
  let(:user) { User.first }
  let(:expected_options) do
    user.couple.users.map do |user|
      [user.username, user.id]
    end
  end

  before { create_list(:couple, rand(2..5)) }

  it { is_expected.to match_array(expected_options) }
end
