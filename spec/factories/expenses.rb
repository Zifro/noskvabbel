# frozen_string_literal: true

FactoryBot.define do
  factory :expense do
    amount { Faker::Number.decimal(l_digits: 2) }
    label { Faker::Company.name }
    spent_on { Faker::Date.between(from: 2.days.ago, to: Time.zone.today) }
    user
    created_by(factory: :user)
  end
end
