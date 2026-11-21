# frozen_string_literal: true

class User < ApplicationRecord
  acts_as_authentic do |c|
    c.crypto_provider = ::Authlogic::CryptoProviders::SCrypt
  end

  belongs_to :couple, optional: true
  has_many :expenses, dependent: :restrict_with_exception

  validates :username, uniqueness: { case_sensitive: false }
  validates :gender, inclusion: { in: %w[M F], allow_nil: true }

  # Recalculates and persists the cached total of this user's expenses in a
  # single atomic UPDATE (the database computes the sum in the same statement),
  # skipping validations: expenses_total is a derived cache, and saving an
  # expense must not fail because of unrelated User validations.
  def update_expenses_total!
    sql = 'expenses_total = (SELECT COALESCE(SUM(amount), 0) FROM expenses WHERE expenses.user_id = ?)'
    # rubocop:disable-next Rails/SkipsModelValidations -- derived cache column, written atomically
    self.class.where(id: id).update_all([sql, id])
    reload
  end
end
