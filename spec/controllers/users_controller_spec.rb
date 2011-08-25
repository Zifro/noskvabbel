require 'spec_helper'

describe UsersController do
  
  before(:each) do
    @uc = UsersController.new
  end

  it "should have an edit action" do
    @uc.should respond_to(:edit)
  end

  it "should have an update action" do
    @uc.should respond_to(:update)
  end

end
