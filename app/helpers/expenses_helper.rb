# frozen_string_literal: true

module ExpensesHelper
  # Returns an Array of options to be used in a select
  def options_for_select(selected_user)
    selected_user.couple.users.collect do |user|
      [user.username, user.id]
    end
  end
end
