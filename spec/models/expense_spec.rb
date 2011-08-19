require 'spec_helper'

describe Expense do
  
  before(:all) do
    User.destroy_all
    @user1 = User.create!(:username              => 'lover1',
                          :email                 => "lover1@domain.tld",
                          :password              => 'password',
                          :password_confirmation => 'password')
    Expense.destroy_all
  end
  
  before(:each) do
    @valid_expense = Expense.create!(:amount => 50, :label => "grocery", :spent_on => 2.days.ago, :user => User.first)
  end
  
  it "should have an amount attribute" do
    e = Expense.new
    e.attributes.should have_key("amount")
    e.should respond_to(:amount)
    e.should respond_to(:amount=)
  end
  
  it "should have an a label attribute" do
    e = Expense.new
    e.attributes.should have_key("label")
    e.should respond_to(:amount)
    e.should respond_to(:amount=)
  end

  it "should have an a spent_on attribute" do
    e = Expense.new
    e.attributes.should have_key("spent_on")
    e.should respond_to(:spent_on)
    e.should respond_to(:spent_on=)
  end

  it "should belongs to a user" do
    user = User.first
    e = Expense.create!(:amount => 50, :label => "grocery", :spent_on => 2.days.ago, :user => user)
    e.user.should == user  
  end

  it "should not be valid without an amount" do
    @valid_expense.amount = nil
    @valid_expense.should_not be_valid
  end

  it "should not be valid without a user" do
    @valid_expense.user = nil
    @valid_expense.should_not be_valid
  end
  
  it "should not be valid without a label" do
    @valid_expense.label = nil
    @valid_expense.should_not be_valid
  end
  
  it "should not be valid without a spent_on" do
    @valid_expense.spent_on = nil
    @valid_expense.should_not be_valid
  end
  
  it "should not be valid with an amount of 0" do
    @valid_expense.amount = 0
    @valid_expense.should_not be_valid
  end
  
  it "should not be valid with an amount lesser than 0.01" do
    @valid_expense.amount = 0.009
    @valid_expense.should_not be_valid
  end
  
  it "should not be valid with a non-numerical amount" do
    @valid_expense.amount = 'xkcd'
    @valid_expense.should_not be_valid
  end
  
end
