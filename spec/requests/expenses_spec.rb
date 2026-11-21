# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Expenses' do
  let(:password) { 'curiou5 passw0rd' }
  let(:user) { create(:user, :in_couple, password: password) }
  let(:today) { Time.zone.today }

  describe 'access protection' do
    it 'redirects anonymous visitors to the login page' do
      get expenses_path
      expect(response).to redirect_to(login_path)
    end

    it 'redirects logged-in users who are not in a couple' do
      create(:user, username: 'solodude', password: password)
      post user_sessions_path, params: { user_session: { username: 'solodude', password: password } }

      get expenses_path
      expect(response).to redirect_to(login_path)
    end

    it 'redirects anonymous visitors away from the load_more action' do
      get load_more_expenses_path(mode: '30_days', before: Time.zone.today)
      expect(response).to redirect_to(login_path)
    end
  end

  describe 'when logged in as a user in a couple' do
    before do
      post user_sessions_path, params: { user_session: { username: user.username, password: password } }
    end

    describe 'GET /expenses' do
      it 'lists the expenses of the couple' do
        expense = create(:expense, user: user, created_by: user, label: 'Groceries')
        create(:expense, label: 'Purchase of another couple')

        get expenses_path
        expect(response).to have_http_status(:ok)
        expect(response.body).to include('Groceries')
        expect(response.body).not_to include('Purchase of another couple')
        expect(expense.user.couple.expenses).to contain_exactly(expense)
      end

      it 'deletes through a Turbo-confirmed DELETE request, not by opening the details page' do
        expense = create(:expense, user: user, created_by: user, label: 'Groceries')

        get expenses_path

        expect(response.body).to include(
          %(<a data-turbo-method="delete" data-turbo-confirm="Are you sure?" href="#{expense_path(expense)}">Delete</a>)
        )
        expect(response.body).not_to include('data-confirm')
      end

      it 'only lists the expenses of the last 30 days, but balances all expenses' do
        balanced_user = user.couple.users.first
        create(:expense, user: balanced_user, created_by: user, label: 'Recent purchase',
                         spent_on: today, amount: 10)
        create(:expense, user: balanced_user, created_by: user, label: 'Ancient purchase',
                         spent_on: 45.days.ago.to_date, amount: 20)

        get expenses_path

        expect(response).to have_http_status(:ok)
        expect(response.body).to include('Recent purchase')
        expect(response.body).not_to include('Ancient purchase')
        expect(response.body).to include('€ 30,00')
      end

      it 'displays the cached expenses_total of the users instead of recalculating it' do
        balanced_user = user.couple.users.first
        create(:expense, user: balanced_user, created_by: user, label: 'Recent purchase', spent_on: today, amount: 10)
        balanced_user.update!(expenses_total: 999.99)

        get expenses_path

        balance_row = response.body[%r{<tr class="balance" id="balance_user_1">.*?</tr>}m]
        expect(balance_row).to include('€ 999,99')
        expect(balance_row).not_to include('€ 10,00')
      end

      it 'shows the three lazy-loading buttons with the year of the oldest displayed expense' do
        create(:expense, user: user, created_by: user, label: 'Displayed',
                         spent_on: 10.days.ago.to_date)
        create(:expense, user: user, created_by: user, label: 'Older',
                         spent_on: 60.days.ago.to_date)

        get expenses_path

        expect(response.body).to include('Load 30 more days')
        expect(response.body).to include("Load the rest of #{10.days.ago.year}")
        expect(response.body).to include('Load all remaining expenses')
        # the "30 more days" link is anchored on the oldest theoretical date of the
        # loaded window (today - 30 days), not on the actual oldest expense
        expect(response.body).to include("before=#{30.days.ago.to_date}&amp;mode=30_days")
        # the "rest of year" link points at the year of the oldest displayed expense
        expect(response.body).to include("before=#{10.days.ago.to_date}&amp;mode=rest_of_year")
        expect(response.body).to include("year=#{10.days.ago.year}")
      end

      it 'hides the lazy-loading buttons when every expense is within the last 30 days' do
        create(:expense, user: user, created_by: user, label: 'Recent', spent_on: today)

        get expenses_path

        expect(response.body).to include('Recent')
        expect(response.body).not_to include('Load 30 more days')
        expect(response.body).not_to include('Load the rest of')
        expect(response.body).not_to include('Load all remaining expenses')
      end

      it 'still shows the balance lines and the buttons when no expense falls within the last 30 days' do
        create(:expense, user: user, created_by: user, label: 'Old only', spent_on: 100.days.ago.to_date)

        get expenses_path

        expect(response.body).not_to include('Old only')
        expect(response.body).to include('balance_user_1')
        expect(response.body).to include('Load 30 more days')
      end

      it 'shows the empty-state message when the couple has no expense at all' do
        get expenses_path

        expect(response.body).to include('No expenses yet')
        expect(response.body).not_to include('Load 30 more days')
      end
    end

    describe 'GET /expenses/load_more' do
      let(:turbo_stream_headers) { { 'Accept' => 'text/vnd.turbo-stream.html' } }

      it 'appends the next 30-day window to the table as a Turbo Stream' do
        displayed = create(:expense, user: user, created_by: user, label: 'Displayed', spent_on: today - 5)
        create(:expense, user: user, created_by: user, label: 'Next chunk', spent_on: today - 40)
        create(:expense, user: user, created_by: user, label: 'Too old', spent_on: today - 80)

        edge = 30.days.ago.to_date
        get load_more_expenses_path(mode: '30_days', before: edge, oldest: displayed.spent_on),
            headers: turbo_stream_headers

        expect(response).to have_http_status(:ok)
        expect(response.media_type).to eq('text/vnd.turbo-stream.html')
        expect(response.body).to include('action="append"')
        expect(response.body).to include('target="expenses_rows"')
        expect(response.body).to include('Next chunk')
        expect(response.body).not_to include('Too old')
        expect(response.body).not_to include('Displayed')
        # the "30 more days" link now points 30 days before the current theoretical edge
        expect(response.body).to include("before=#{edge - 30}&amp;mode=30_days")
        expect(response.body).to include('Load 30 more days')
      end

      it 'keeps walking the 30-day window backwards even across gaps wider than 30 days' do
        create(:expense, user: user, created_by: user, label: 'Latest expense', spent_on: today - 13)
        create(:expense, user: user, created_by: user, label: 'After a long gap', spent_on: today - 72)

        edge = 30.days.ago.to_date
        oldest = 13.days.ago.to_date

        # first 30-day window before the edge contains no expense (the gap is wider
        # than 30 days), but the link must still move 30 days backwards
        get load_more_expenses_path(mode: '30_days', before: edge, oldest: oldest), headers: turbo_stream_headers
        expect(response.body).not_to include('After a long gap')
        expect(response.body).to include("before=#{edge - 30}&amp;mode=30_days")

        # the next window reaches the expense after the gap
        get load_more_expenses_path(mode: '30_days', before: edge - 30, oldest: oldest), headers: turbo_stream_headers
        expect(response.body).to include('After a long gap')
      end

      it 'appends the remaining expenses of the requested year with mode rest_of_year' do
        boundary = Date.new(2024, 6, 15)
        create(:expense, user: user, created_by: user, label: 'Same year earlier', spent_on: Date.new(2024, 6, 1))
        create(:expense, user: user, created_by: user, label: 'Same year start', spent_on: Date.new(2024, 1, 1))
        create(:expense, user: user, created_by: user, label: 'Previous year', spent_on: Date.new(2023, 12, 31))
        create(:expense, user: user, created_by: user, label: 'After boundary', spent_on: Date.new(2024, 6, 20))

        get load_more_expenses_path(mode: 'rest_of_year', before: boundary, year: 2024), headers: turbo_stream_headers

        expect(response.body).to include('Same year earlier')
        expect(response.body).to include('Same year start')
        expect(response.body).not_to include('Previous year')
        expect(response.body).not_to include('After boundary')
        # the button now points at the previous year
        expect(response.body).to include('Load the rest of 2023')
      end

      it 'steps the rest-of-year button down one year per click and loads each year' do
        create(:expense, user: user, created_by: user, label: 'In 2026', spent_on: Date.new(2026, 11, 8))
        create(:expense, user: user, created_by: user, label: 'Rest of 2026', spent_on: Date.new(2026, 1, 21))
        create(:expense, user: user, created_by: user, label: 'All of 2025', spent_on: Date.new(2025, 6, 15))
        create(:expense, user: user, created_by: user, label: 'All of 2024', spent_on: Date.new(2024, 3, 3))

        get load_more_expenses_path(mode: 'rest_of_year', before: Date.new(2026, 11, 8), year: 2026),
            headers: turbo_stream_headers
        expect(response.body).to include('Rest of 2026')
        expect(response.body).not_to include('All of 2025')
        expect(response.body).to include('Load the rest of 2025')

        get load_more_expenses_path(mode: 'rest_of_year', before: Date.new(2026, 1, 21), year: 2025),
            headers: turbo_stream_headers
        expect(response.body).to include('All of 2025')
        expect(response.body).not_to include('All of 2024')
        expect(response.body).to include('Load the rest of 2024')

        get load_more_expenses_path(mode: 'rest_of_year', before: Date.new(2025, 6, 15), year: 2024),
            headers: turbo_stream_headers
        expect(response.body).to include('All of 2024')
      end

      it 'appends every remaining expense with mode all_remaining and then hides the buttons' do
        boundary = Date.new(2024, 6, 15)
        create(:expense, user: user, created_by: user, label: 'Same year', spent_on: Date.new(2024, 1, 1))
        create(:expense, user: user, created_by: user, label: 'Way back', spent_on: Date.new(2019, 3, 3))

        get load_more_expenses_path(mode: 'all_remaining', before: boundary), headers: turbo_stream_headers

        expect(response.body).to include('Same year')
        expect(response.body).to include('Way back')
        expect(response.body).to include('action="replace"')
        expect(response.body).to include('target="load_more_buttons"')
        expect(response.body).not_to include('Load 30 more days')
      end

      it 'never appends expenses belonging to another couple' do
        create(:expense, label: 'Foreign expense', spent_on: Date.new(2020, 1, 1))

        get load_more_expenses_path(mode: 'all_remaining', before: today), headers: turbo_stream_headers

        expect(response.body).not_to include('Foreign expense')
      end

      it 'answers 400 for an unknown mode' do
        get load_more_expenses_path(mode: 'nope', before: today), headers: turbo_stream_headers

        expect(response).to have_http_status(:bad_request)
      end

      it 'answers 400 for a missing or invalid before date' do
        get load_more_expenses_path(mode: '30_days'), headers: turbo_stream_headers
        expect(response).to have_http_status(:bad_request)

        get load_more_expenses_path(mode: '30_days', before: 'not-a-date'), headers: turbo_stream_headers
        expect(response).to have_http_status(:bad_request)
      end

      it 'redirects to the main page for non Turbo Stream requests' do
        get load_more_expenses_path(mode: 'all_remaining', before: today)

        expect(response).to redirect_to(expenses_path)
      end
    end

    describe 'GET /expenses/new' do
      it 'renders the expense form' do
        get new_expense_path
        expect(response).to have_http_status(:ok)
        expect(response.body).to include('expense[label]')
      end
    end

    describe 'POST /expenses' do
      let(:valid_expense_params) do
        {
          label: 'Restaurant',
          amount: '42.50',
          user_id: user.id,
          'spent_on(1i)': today.year.to_s,
          'spent_on(2i)': today.month.to_s,
          'spent_on(3i)': today.day.to_s
        }
      end

      it 'creates an expense for the user and redirects to the list' do
        expect do
          post expenses_path, params: { expense: valid_expense_params }
        end.to change(Expense, :count).by(1)

        expect(response).to redirect_to(expenses_path)
        expect(flash[:notice]).to eq('Expense successfully recorded')

        expense = Expense.order(:id).last
        expect(expense.label).to eq('Restaurant')
        expect(expense.amount).to eq(42.5)
        expect(expense.spent_on).to eq(today)
        expect(expense.created_by).to eq(user)
      end
    end

    describe 'GET /expenses/:id' do
      it 'shows the expense' do
        expense = create(:expense, user: user, created_by: user, label: 'Cinema')

        get expense_path(expense)
        expect(response).to have_http_status(:ok)
        expect(response.body).to include('Cinema')
      end
    end

    describe 'GET /expenses/:id/edit' do
      it 'renders the edit form' do
        expense = create(:expense, user: user, created_by: user)

        get edit_expense_path(expense)
        expect(response).to have_http_status(:ok)
        expect(response.body).to include('expense[label]')
      end
    end

    describe 'PATCH /expenses/:id' do
      it 'updates the expense and redirects to the list' do
        expense = create(:expense, user: user, created_by: user, label: 'Books')

        patch expense_path(expense), params: { expense: { label: 'Better books' } }

        expect(response).to redirect_to(expenses_path)
        expect(flash[:notice]).to eq('Expense successfully updated')
        expect(expense.reload.label).to eq('Better books')
      end
    end

    describe 'DELETE /expenses/:id' do
      it 'destroys the expense and redirects to the list' do
        expense = create(:expense, user: user, created_by: user)

        expect do
          delete expense_path(expense)
        end.to change(Expense, :count).by(-1)

        expect(response).to redirect_to(expenses_path)
        expect(flash[:notice]).to eq('Expense successfully deleted')
      end

      it 'refuses to destroy an expense belonging to another couple' do
        expense = create(:expense, label: 'Purchase of another couple')

        expect do
          delete expense_path(expense)
        end.not_to change(Expense, :count)

        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
