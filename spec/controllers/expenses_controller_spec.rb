require 'spec_helper'

describe ExpensesController do
  
  before(:each) do
    @ec = ExpensesController.new
  end

  it "should have an index action" do
    @ec.should respond_to(:index)
  end

  it "should have an new action" do
    @ec.should respond_to(:new)
  end

  context "the create action" do
    
    it "should exist" do
      @ec.should respond_to(:create)
    end
    
    it "should create a new expense from params[:expense]" do
      pending
    end
    
  end

end
