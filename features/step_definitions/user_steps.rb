Given /^I have an account with credentials ([^\/]+)\/(.+)$/ do |username, password|
  User.create!(:username              => username,
               :email                 => "#{username}@domain.tld",
               :password              => password,
               :password_confirmation => password
  )
end

Given /^I am logged in as (.+)$/ do |username|
  User.create!(:username              => username,
               :email                 => "#{username}@domain.tld",
               :password              => "tagada",
               :password_confirmation => "tagada"
  )
  visit "/login"
  fill_in "user_session[username]", :with => username
  fill_in "user_session[password]", :with => "tagada"
  click_button "Login"
end

Given /^I'm not logged in$/ do
  visit "/logout"
end

Given /^there is no (.+)$/ do |username|
  User.delete_all("username='#{username}'")
end