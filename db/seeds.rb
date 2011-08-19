# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)

User.create!(:username              => 'guillaume',
             :email                 => "guillaume@bleu04.fr",
             :password              => "mot_de_passe",
             :password_confirmation => "mot_de_passe"
)
User.create!(:username              => 'laetitia',
             :email                 => "laetitia@bleu04.fr",
             :password              => "petit conan",
             :password_confirmation => "petit conan"
)


Couple.create!(:users => [User.find_by_username('guillaume'), User.find_by_username('laetitia')])