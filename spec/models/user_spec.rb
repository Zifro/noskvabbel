require 'spec_helper'

describe User do

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

end
