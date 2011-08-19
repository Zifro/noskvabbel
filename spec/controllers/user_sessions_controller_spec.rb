require 'spec_helper'

describe UserSessionsController do

  before(:each) do
    @usc = UserSessionsController.new
  end

  it "should have a new action" do
    @usc.should respond_to(:new)
  end

  it "should have a create action" do
    @usc.should respond_to(:create)
  end

  it "should have a destroy action" do
    @usc.should respond_to(:destroy)
  end

end
