class ExpensesController < ApplicationController

  before_filter :verify_the_user_is_in_couple

  def index
    @expenses = current_user.couple.expenses
  end
  
  
  protected
  
  def verify_the_user_is_in_couple
    unless current_user.couple
      redirect_to new_user_session_path, :notice => "#{flash[:notice]}... sorry, you're not in couple yet"
    end
  end

end
