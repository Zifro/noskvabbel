require 'spec_helper'

describe Couple do
  
  before(:all) do
    User.destroy_all
    User.create!(:username              => 'lover1',
                 :email                 => "lover1@domain.tld",
                 :password              => 'password',
                 :password_confirmation => 'password')
    User.create!(:username              => 'lover2',
                 :email                 => "lover2@domain.tld",
                 :password              => 'password',
                 :password_confirmation => 'password')
  end

  before(:each) do
    @couple = Couple.create!(:users => [User.find_by_username('lover1'), User.find_by_username('lover2')])
  end
  
  it "should have users" do
    Couple.new.should respond_to(:users)
  end

  it "should not be valid without users" do
    @couple.users = []
    @couple.should_not be_valid
  end
  
  it "should not be valid with only one user" do
    @couple.users = [User.first]
    @couple.should_not be_valid
  end
  
  it "should be valid with two users" do
    @couple.should be_valid
  end
  
  it "should not be valid with three or more users" do
    pending "generate a lot of users on the fly for this test"
  end
  
  it "should have expenses" do
    Couple.new.should respond_to(:expenses)
  end

end
