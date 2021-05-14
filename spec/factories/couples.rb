# frozen_string_literal: true

FactoryBot.define do
  factory :couple do
    users { create_list(:user, 2) }
  end
end
