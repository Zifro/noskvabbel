# frozen_string_literal: true

class ExpensesController < ApplicationController
  include ActionView::Helpers::NumberHelper

  # Number of days of expenses loaded at once on the main page and by the
  # "Load 30 more days" button
  DAYS_PER_LOAD = 30

  before_action :verify_the_user_is_in_couple

  # Lists the balance lines and the expenses of the last 30 days recorded for
  # the couple of the user; older expenses are lazy-loaded via #load_more
  def index
    @expenses = current_user.couple.expenses.includes(:user).where(spent_on: initial_window_start..)
    load_users
    prepare_lazy_loading
  end

  # Appends more expenses to the table of the main page, as a Turbo Stream:
  # - mode=30_days: the 30 days before the oldest expense currently displayed
  # - mode=rest_of_year: the rest of the year of the oldest expense displayed
  # - mode=all_remaining: every older expense of the couple
  # The `before` param is the spent_on date of the oldest expense displayed.
  def load_more
    boundary = parse_boundary_date
    return head :bad_request unless boundary

    @expenses = expenses_before(boundary)
    return head :bad_request if @expenses.nil?

    prepare_lazy_loading(boundary)
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to expenses_path }
    end
  end

  # Displays an expense
  def show
    @expense = Expense.find(params[:id])
    # TODO: add a filter so that only expenses linked to the couple of the user can be displayed
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
    @expense = current_user.couple.expenses.find(params[:id])
    if @expense.destroy
      redirect_to(expenses_path, notice: 'Expense successfully deleted')
    else
      redirect_to(expenses_path, error: 'Expense could not be deleted')
    end
  end

private

  def verify_the_user_is_in_couple
    redirect_to login_path, notice: "#{flash[:notice]}... sorry, you're not in couple yet" unless current_user.couple
  end

  def load_users
    @users = current_user.couple.users.collect do |user|
      {
        username: user.username,
        total: number_to_currency(user.expenses_total, unit: '€ ', separator: ',', delimiter: ' ')
      }
    end
  end

  def initial_window_start
    DAYS_PER_LOAD.days.ago.to_date
  end

  # Sets @oldest_expense_date (date of the oldest expense displayed, used as
  # the `before` boundary of the lazy-loading buttons) and @all_expenses_loaded
  def prepare_lazy_loading(fallback_boundary = nil)
    @oldest_expense_date = @expenses.map(&:spent_on).min || fallback_boundary || initial_window_start
    @all_expenses_loaded = current_user.couple.expenses.where(spent_on: ...@oldest_expense_date).none?
  end

  def parse_boundary_date
    Date.iso8601(params[:before].to_s)
  rescue Date::Error
    nil
  end

  def expenses_before(boundary)
    scope = current_user.couple.expenses.includes(:user).where(spent_on: ...boundary)
    case params[:mode]
    when '30_days' then scope.where(spent_on: (boundary - DAYS_PER_LOAD)...boundary)
    when 'rest_of_year' then scope.where(spent_on: Date.new(boundary.year, 1, 1)...boundary)
    when 'all_remaining' then scope
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
