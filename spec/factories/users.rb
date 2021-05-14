# frozen_string_literal: true

GENDERS = %w[M F].freeze

FactoryBot.define do
  factory :user do
    username { Faker::Internet.username }
    email { Faker::Internet.email }
    gender { GENDERS.sample }
    password { Faker::Internet.password }

    trait :in_couple do |_user|
      couple { association :couple, strategy: :build }

      after(:create) do |user|
        user.couple.users << user
      end
    end

    trait :with_expenses do |_user|
      transient do
        expenses_count { rand(3..7) }
      end

      after(:create) do |user, evaluator|
        create_list(:expense, evaluator.expenses_count, user: user, created_by: user)
      end
    end
  end
end
