Given /^user (\S+) is in couple$/ do |user|
  lover1 = User.find_by_username('zifro')
  lover2 = User.create!(:username              => 'other',
                        :email                 => "other@domain.tld",
                        :password              => 'password',
                        :password_confirmation => 'password')
  Couple.create!(:users => [lover1, lover2])
end
