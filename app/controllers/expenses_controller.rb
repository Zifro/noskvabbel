# frozen_string_literal: true

class ExpensesController < ApplicationController
  include ActionView::Helpers::NumberHelper

  before_action :verify_the_user_is_in_couple

  # Lists the expenses recorded for the couple of the user
  def index
    @expenses = current_user.couple.expenses
    load_users
  end

  # Displays an expense
  def show
    @expense = Expense.find(params[:id])
    # TODO: add a filter so that only expenses linked to the couple of the user can be displayed
    respond_to do |format|
      format.html
      format.js
    end
  end

  # Display a form for the user to create a new expense
  def new
    @expense = Expense.new(user: current_user)
  end

  # Creates a new expense
  def create
    @expense = Expense.new(expense_params)
    @expense.created_by = current_user
    if @expense.save
      redirect_to(expenses_path, notice: 'Expense successfully recorded')
    else
      render new_expense_path(@expense)
    end
  end

  # Displays a form for the user to update the expense passed as parameter
  def edit
    @expense = Expense.find(params[:id])
    # TODO: add a filter so that only expenses linked to the couple of the user can be edited
  end

  # Updates an expenses from what the user has put into params[:expenses]
  def update
    @expense = Expense.find(params[:id])
    # TODO: add a filter so that only expenses linked to the couple of the user can be updated
    if @expense.update(expense_params)
      redirect_to(expenses_path, notice: 'Expense successfully updated')
    else
      render action: :edit
    end
  end

  # Destroys an expense from what the user has passed as parameter
  def destroy
    respond_to do |format|
      @expense = Expense.find(params[:id])
      # TODO: add a filter so that only expenses linked to the couple of the user can be destroyed
      if @expense.destroy
        load_users
        format.html { redirect_to(expenses_path, notice: 'Expense successfully deleted') }
      else
        format.html { redirect_to(expenses_path, error: 'Expense could not be deleted') }
      end
      format.js
    end
  end

private

  def verify_the_user_is_in_couple
    redirect_to login_path, notice: "#{flash[:notice]}... sorry, you're not in couple yet" unless current_user.couple
  end

  def load_users
    @users = current_user.couple.users.collect do |user|
      total = user.expenses.inject(0) { |sum, e| sum + e.amount }
      {
        username: user.username,
        total: number_to_currency(total, unit: '€ ', separator: ',', delimiter: ' ')
      }
    end
  end

  def expense_params
    params.require(:expense).permit(
      :label,
      :amount,
      :user_id,
      :"spent_on(1i)",
      :"spent_on(2i)",
      :"spent_on(3i)"
    ).to_h
  end
end
