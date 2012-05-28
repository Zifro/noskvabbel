Given /^user (\S+) has recorded the following expenses:$/ do |user, table|
  # table is a Cucumber::Ast::Table
  user = User.find_by_username(user)
  table.hashes.each do |expense|
    exp = Expense.new(
      :label    => expense[:label],
      :amount   => expense[:amount],
      :spent_on => "#{expense[:spent_on_1i]}-#{expense[:spent_on_2i]}-#{expense[:spent_on_3i]}".to_date,
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

Then /^the "([^"]*)" field should contain the date of today$/ do |field|
  date = Date.today.strftime('%Y-%m-%d')
  field = find_field(field)
  field_value = (field.tag_name == 'textarea') ? field.text : field.value
  if field_value.respond_to? :should
    field_value.should =~ /#{date}/
  else
    assert_match(/#{date}/, field_value)
  end
end