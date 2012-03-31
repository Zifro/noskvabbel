# coding: utf-8

class ExpensesController < ApplicationController
  
  include ActionView::Helpers::NumberHelper

  before_filter :verify_the_user_is_in_couple

  # Lists the expenses recorded for the couple of the user
  def index
    @expenses = current_user.couple.expenses
    get_users
  end
  
  # Displays an expense
  def show
    @expense = Expense.find(params[:id])
    #TODO: add a filter so that only expenses linked to the couple of the user can be displayed
    respond_to do |format|
      format.html
      format.js
    end
  end
  
  # Display a form for the user to create a new expense
  def new
    @expense = Expense.new(:user => current_user)
  end
  
  # Creates a new expense
  def create
    @expense = Expense.new(params[:expense])
    @expense.created_by = current_user
    if @expense.save
      redirect_to(expenses_path, :notice => 'Expense successfully recorded')
    else
      render new_expense_path(@expense)
    end
  end

  # Displays a form for the user to update the expense passed as parameter
  def edit
    @expense = Expense.find(params[:id])
    #TODO: add a filter so that only expenses linked to the couple of the user can be displayed
  end
  
  # Updates an expenses from what the user has put into params[:expenses]
  def update
    @expense = Expense.find(params[:id])
    #TODO: add a filter so that only expenses linked to the couple of the user can be displayed
    if @expense.update_attributes(params[:expense])
      redirect_to(expenses_path, :notice => 'Expense successfully updated')
    else
      render :action => :edit
    end
  end
  
  # Destroys an expense from what the user has passed as parameter
  def destroy
    respond_to do |format|
      @expense = Expense.find(params[:id])
      #TODO: add a filter so that only expenses linked to the couple of the user can be displayed
      if @expense.destroy
        get_users
        format.html { redirect_to(expenses_path, :notice => 'Expense successfully deleted') }
        format.js
      else
        format.html { redirect_to(expenses_path, :error => 'Expense could not be deleted') }
        format.js
      end
    end
  end
  
  protected
  
  def verify_the_user_is_in_couple
    unless current_user.couple
      redirect_to login_path, :notice => "#{flash[:notice]}... sorry, you're not in couple yet"
    end
  end

  def get_users
    @users = current_user.couple.users.collect do |user|
        total = user.expenses.inject(0) { |total, e| total += e.amount }
        { :username => user.username, :total => number_to_currency(total, :unit => '€ ', :separator => ',', :delimiter => ' ') }
    end
  end

end
