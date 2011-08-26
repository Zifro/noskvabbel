# coding: utf-8

module ExpensesHelper

  # Displays the balance for the couple
  def display_balance(couple)
    couple.users.collect do |user|
      total = user.expenses.inject(0) { |total, e| total += e.amount }
      "#{user.username} (#{number_to_currency(total, :unit => '', :separator => ',', :delimiter => ' ')})"
    end.join(' / ')
  end

end
