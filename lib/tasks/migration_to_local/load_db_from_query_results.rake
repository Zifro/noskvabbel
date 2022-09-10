# frozen_string_literal: true

namespace :migration_to_local do
  task load_db_from_query_results: %i[
    load_expenses_from_query_results
    load_users_from_query_results
    load_couples_from_query_results
    environment
  ] do
    puts "All done (hopefully)"
  end

  task load_expenses_from_query_results: %i[load_users_from_query_results environment] do
    STDOUT.write "Loading expenses from query results: "

    preparator = ExpenseAttributesPreparator.new
    expense_attributes = QueryResultParser.parse(Rails.root.join('expenses.txt'))

    expense_attributes.each do |attributes|
      prepared_attributes = preparator.prepare(attributes)
      expense = Expense.new(prepared_attributes)
      STDOUT.write(expense.save ? '.' : 'E')
    end

    puts "done!"
  end

  task load_users_from_query_results: %i[load_couples_from_query_results environment] do
    STDOUT.write "Loading users from query results: "

    user_attributes = QueryResultParser.parse(Rails.root.join('users.txt'))

    user_attributes.each do |attributes|
      user = User.new(attributes)
      STDOUT.write(user.save ? '.' : 'E')
    end

    puts "done!"
  end

  task load_couples_from_query_results: :environment do
    STDOUT.write "Loading couples from query results: "

    couple_attributes = QueryResultParser.parse(Rails.root.join('couples.txt'))

    couple_attributes.each do |attributes|
      couple = Couple.new(attributes)
      STDOUT.write(couple.save ? '.' : 'E')
    end

    puts "done!"
  end
end
