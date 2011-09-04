require 'spec_helper'

describe ExpensesController do
  
  before(:each) do
    @ec = ExpensesController.new
  end

  it "should have an index action" do
    @ec.should respond_to(:index)
  end

  it "should have a new action" do
    @ec.should respond_to(:new)
  end

  it "should have a create action" do
    @ec.should respond_to(:create)
  end
  
  it "should have an edit action" do
    @ec.should respond_to(:edit)
  end

  it "should have an update action" do
    @ec.should respond_to(:update)
  end

  it "should have a destroy action" do
    @ec.should respond_to(:destroy)
  end

  it "should have a show action" do
    @ec.should respond_to(:show)
  end

end
