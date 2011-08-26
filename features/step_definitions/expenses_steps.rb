Given /^user (\S+) has recorded following expenses:$/ do |user, table|
  # table is a Cucumber::Ast::Table
  user = User.find_by_username(user)
  table.hashes.each do |expense|
    exp = Expense.new(
      :label    => expense[:label],
      :amount   => expense[:amount],
      :spent_on => expense[:spent_on].to_date
    )
    exp.user = user # due to the attr_accessible
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