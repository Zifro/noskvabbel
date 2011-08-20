class ExpensesController < ApplicationController

  before_filter :verify_the_user_is_in_couple

  # Lists the expenses recorded for the couple of the user
  def index
    @expenses = current_user.couple.expenses
  end
  
  # Display a form for the user to create a new expense
  def new
    @expense = Expense.new
  end
  
  # Creates a new expense
  def create
    @expense = Expense.new(params[:expense])
    @expense.user = current_user
    if @expense.save
      redirect_to(expenses_path, :notice => 'Expense successfully recorded')
    else
      render new_expense_path(@expense)
    end
  end
  
  protected
  
  def verify_the_user_is_in_couple
    unless current_user.couple
      redirect_to login_path, :notice => "#{flash[:notice]}... sorry, you're not in couple yet"
    end
  end

end
