require 'spec_helper'

describe ExpensesController do
  
  before(:each) do
    @ec = ExpensesController.new
  end

  it "should have an index action" do
    @ec.should respond_to(:index)
  end

end
