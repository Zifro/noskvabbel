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
    @oldest_theoretical_date = initial_window_start
    @expenses = couple_expenses.where(spent_on: @oldest_theoretical_date..)
    load_users
    prepare_lazy_loading
  end

  # Appends more expenses to the table of the main page, as a Turbo Stream:
  # - mode=30_days: the 30 days before `before`, which is the oldest theoretical
  #   date of the loaded window, so that the window keeps moving backwards by 30
  #   days per click even when expenses are more than 30 days apart (e.g. a
  #   month-long vacation with no expense)
  # - mode=rest_of_year: the not-yet-displayed expenses of year `year`; the button
  #   then steps down to year-1, so that "Load the rest of 2026" becomes "Load the
  #   rest of 2025", and so on, year after year
  # - mode=all_remaining: every older expense of the couple
  # `before` is the exclusive upper bound of the chunk to load, `oldest` the actual
  # spent_on date of the oldest expense displayed so far, and `year` the year the
  # rest_of_year button currently points at.
  def load_more
    boundary = parse_date_param(params[:before])
    oldest = parse_date_param(params[:oldest]) || boundary
    return head :bad_request unless boundary

    @expenses, @oldest_theoretical_date, year = expenses_to_load(boundary)
    return head :bad_request if @expenses.nil?

    prepare_lazy_loading_after_load(oldest, year)
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to expenses_path }
    end
  end

  # Displays an expense
  def show
    @expense = Expense.find(params.expect(:id))
    # TODO: add a filter so that only expenses linked to the couple of the user can be displayed
  end

  # Display a form for the user to create a new expense
  def new
    @expense = Expense.new(user: current_user)
  end

  # Displays a form for the user to update the expense passed as parameter
  def edit
    @expense = Expense.find(params.expect(:id))
    # TODO: add a filter so that only expenses linked to the couple of the user can be edited
  end

  # Creates a new expense
  def create
    @expense = Expense.new(expense_params)
    @expense.created_by = current_user
    if @expense.save
      redirect_to(expenses_path, notice: t('expense_successfully_recorded'))
    else
      render new_expense_path(@expense)
    end
  end

  # Updates an expenses from what the user has put into params[:expenses]
  def update
    @expense = Expense.find(params.expect(:id))
    # TODO: add a filter so that only expenses linked to the couple of the user can be updated
    if @expense.update(expense_params)
      redirect_to(expenses_path, notice: t('expense_successfully_updated'))
    else
      render action: :edit
    end
  end

  # Destroys an expense from what the user has passed as parameter
  def destroy
    @expense = current_user.couple.expenses.find(params.expect(:id))
    if @expense.destroy
      redirect_to(expenses_path, notice: t('expense_successfully_deleted'))
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

  # Sets @oldest_expense_date (actual date of the oldest expense displayed) and
  # @all_expenses_loaded; @next_year_to_load starts at the year of that expense
  def prepare_lazy_loading
    @oldest_expense_date = @expenses.map(&:spent_on).min || @oldest_theoretical_date
    @next_year_to_load = @oldest_expense_date.year
    @all_expenses_loaded = current_user.couple.expenses.where(spent_on: ...@oldest_expense_date).none?
  end

  def parse_date_param(value)
    Date.iso8601(value.to_s)
  rescue Date::Error
    nil
  end

  def parse_year_param(value)
    year = Integer(value, exception: false)
    year if year && (1..9999).cover?(year)
  end

  def couple_expenses
    current_user.couple.expenses.includes(:user)
  end

  # Sets the lazy-loading state after a load_more chunk: the actual oldest expense
  # displayed, the theoretical window edge, the next year to load, and whether
  # every expense of the couple is now displayed
  def prepare_lazy_loading_after_load(oldest, year)
    @oldest_expense_date = @expenses.map(&:spent_on).min || oldest
    @oldest_theoretical_date ||= @oldest_expense_date
    @next_year_to_load = [year || @oldest_expense_date.year, @oldest_expense_date.year].min
    @all_expenses_loaded = current_user.couple.expenses.where(spent_on: ...@oldest_expense_date).none?
  end

  # Returns the expenses to append for the requested mode, along with the new
  # oldest theoretical date of the loaded window (nil to recompute it from the
  # oldest expense) and the next year the rest_of_year button should point at
  # (nil to keep it); nil expenses means the mode is unknown
  def expenses_to_load(boundary)
    case params[:mode]
    when '30_days'
      chunk = couple_expenses.where(spent_on: (boundary - DAYS_PER_LOAD)...boundary)
      [chunk, boundary - DAYS_PER_LOAD, parse_year_param(params[:year])]
    when 'rest_of_year'
      rest_of_year_expenses(boundary)
    when 'all_remaining'
      [couple_expenses.where(spent_on: ...boundary), nil, parse_year_param(params[:year])]
    end
  end

  # The not-yet-displayed expenses of year `year` (defaults to the boundary's
  # year), along with a nil window edge and the next year (year - 1) so that the
  # rest_of_year button steps down one year per click
  def rest_of_year_expenses(boundary)
    year = parse_year_param(params[:year]) || boundary.year
    chunk = couple_expenses.where(spent_on: Date.new(year, 1, 1)...Date.new(year + 1, 1, 1))
                           .where(spent_on: ...boundary)
    [chunk, nil, year - 1]
  end

  def expense_params
    params.expect(
      expense: %i[label
                  amount
                  user_id
                  spent_on(1i)
                  spent_on(2i)
                  spent_on(3i)]
    ).to_h
  end
end
