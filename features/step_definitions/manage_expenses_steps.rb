Given /^user (\S+) is in couple$/ do |user|
  lover1 = User.find_by_username('zifro')
  lover2 = User.create!(:username              => 'other',
                        :email                 => "other@domain.tld",
                        :password              => 'password',
                        :password_confirmation => 'password')
  Couple.create!(:users => [lover1, lover2])
end

Given /^user (\S+) has recorded following expenses:$/ do |user, table|
  # table is a Cucumber::Ast::Table
  user = User.find_by_username(user)
  table.hashes.each do |expense|
    Expense.create!(
      :user     => user,
      :label    => expense[:label],
      :amount   => expense[:amount],
      :spent_on => expense[:spent_on].to_date
    )
  end
end

Then /^I should see the following expenses:$/ do |table|
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