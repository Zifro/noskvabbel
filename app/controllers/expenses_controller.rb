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

  # Displays a form for the user to update the expense passed as parameter
  def edit
    @expense = Expense.find(params[:id])
  end
  
  # Updates an expenses from what the user has put into params[:expenses]
  def update
    @expense = Expense.find(params[:id])
    if @expense.update_attributes(params[:expense])
      redirect_to(expenses_path, :notice => 'Expense successfully updated')
    else
      render edit_expense_path(@expense)
    end
  end
  
  # Destroys an expense from what the user has passed as parameter
  def destroy
    @expense = Expense.find(params[:id])
    if @expense.destroy
      redirect_to(expenses_path, :notice => 'Expense successfully deleted')
    else
      redirect_to(expenses_path, :error => 'Expense could not be deleted')
    end
  end
  
  protected
  
  def verify_the_user_is_in_couple
    unless current_user.couple
      redirect_to login_path, :notice => "#{flash[:notice]}... sorry, you're not in couple yet"
    end
  end

end
