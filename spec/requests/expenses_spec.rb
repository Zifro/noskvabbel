# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Expenses', type: :request do
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
    end
  end
end
