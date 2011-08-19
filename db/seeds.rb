# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)

['guillaume', 'laetitia'].each do |name|
  User.create!(:username              => name,
               :email                 => "#{name}@domain.tld",
               :password              => "#{name} 1",
               :password_confirmation => "#{name} 1"
  )
end