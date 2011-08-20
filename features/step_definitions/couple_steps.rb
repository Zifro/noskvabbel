Given /^user (\S+) is in couple$/ do |user|
  lover1 = User.find_by_username(user)
  lover2 = User.create!(:username              => 'other',
                        :email                 => "other@domain.tld",
                        :password              => 'password',
                        :password_confirmation => 'password')
  Couple.create!(:users => [lover1, lover2])
end

Given /^user (\S+) is in couple with (\S+)$/ do |user1, user2|
  lover1 = User.find_by_username(user1)
  lover2 = User.create!(:username              => user2,
                        :email                 => "other@domain.tld",
                        :password              => 'password',
                        :password_confirmation => 'password')
  Couple.create!(:users => [lover1, lover2])
end