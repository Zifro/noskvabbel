# frozen_string_literal: true

class User < ApplicationRecord
  acts_as_authentic do |c|
    c.crypto_provider = ::Authlogic::CryptoProviders::SCrypt
  end

  belongs_to :couple, optional: true
  has_many :expenses, dependent: :restrict_with_exception

  validates :gender, inclusion: { in: %w[M F], allow_nil: true }
end
