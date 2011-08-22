require 'spec_helper'

describe User do

  before(:all) do
    User.destroy_all
    @user1 = User.create!(:username              => 'lover1',
                          :email                 => "lover1@domain.tld",
                          :gender                => 'F',
                          :password              => 'password',
                          :password_confirmation => 'password')
    @user2 = User.create!(:username              => 'lover2',
                          :email                 => "lover2@domain.tld",
                          :gender                => 'M',
                          :password              => 'password',
                          :password_confirmation => 'password')
  end

  it "should have a username attribute" do
    u = User.new
    u.attributes.should have_key("username")
    u.should respond_to(:username)
    u.should respond_to(:username=)
  end

  it "should have an email attribute" do
    u = User.new
    u.attributes.should have_key("email")
    u.should respond_to(:email)
    u.should respond_to(:email=)
  end

  it "should have a password= method" do
    u = User.new
    u.should respond_to(:password=)
  end

  context "in a couple" do

    it "should have a couple method" do
      u = User.new
      u.should respond_to(:couple)
    end

    it "should belongs to a couple" do
      couple = Couple.create!(:users => [@user1, @user2])
      @user1.couple.should == couple 
    end
           
  end

  context "with expenses" do
    
    it "should have an expenses method" do
      u = User.new
      u.should respond_to(:expenses)
    end

    it "should have many expenses" do
      expense = Expense.new(:amount => 10, :label => "XXX", :spent_on => 2.days.ago)
      expense.user = @user1 # due to attr_accessible not listing :user
      expense.save!
      @user1.expenses.should be_kind_of(Array)
      @user1.expenses.first.should be_kind_of(Expense)
      @user1.expenses.first.amount.should == 10
    end
  
  end

  context "as a gender kind" do

    it "should have a gender attribute" do
      u = User.new
      u.attributes.should have_key("gender")
      u.should respond_to(:gender)
      u.should respond_to(:gender=)
    end

    it "should only accept 'M' or 'F' as gender" do
      u = User.first
      u.gender = 'M'
      u.should be_valid
      u.gender = 'F'
      u.should be_valid
      u.gender = 'X'
      u.should_not be_valid
    end


  end

end
