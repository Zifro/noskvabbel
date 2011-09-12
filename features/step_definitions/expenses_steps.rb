Given /^user (\S+) has recorded following expenses:$/ do |user, table|
  # table is a Cucumber::Ast::Table
  user = User.find_by_username(user)
  table.hashes.each do |expense|
    exp = Expense.new(
      :label    => expense[:label],
      :amount   => expense[:amount],
      :spent_on => expense[:spent_on].to_date,
      :user     => User.find_by_username(expense[:user]),
      :created_by => (expense[:created_by] ? User.find_by_username(expense[:created_by]) : User.find_by_username(user)),
      :created_at => (expense[:created_at] || Date.today)
    )
    exp.created_by = user # due to the attr_accessible
    exp.save!
  end
end

Then /^I should see the following expenses*:$/ do |table|
  # table is a Cucumber::Ast::Table
  table.hashes.each do |expense|
    if page.respond_to? :should
      expense.values.each do |text|
        page.should have_content(text)
      end
    else
      expense.values.each do |text|
        assert page.has_content?(text)
      end
    end
  end
end

Then /^I should not see the following expenses*:$/ do |table|
  # table is a Cucumber::Ast::Table
  table.hashes.each do |expense|
    if page.respond_to? :should
      expense.values.each do |text|
        page.should have_no_content(text)
      end
    else
      expense.values.each do |text|
        assert page.has_no_content?(text)
      end
    end
  end
end