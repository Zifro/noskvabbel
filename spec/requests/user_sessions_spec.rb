# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'UserSessions', type: :request do
  let(:password) { 'curiou5 passw0rd' }
  let(:user) { create(:user, :in_couple, password: password) }

  describe 'GET /login' do
    it 'renders the login form' do
      get login_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include('user_session[username]')
    end
  end

  describe 'POST /user_sessions' do
    context 'with valid credentials' do
      it 'logs the user in and redirects to the expenses' do
        post user_sessions_path, params: { user_session: { username: user.username, password: password } }

        expect(response).to redirect_to(expenses_path)
        expect(flash[:notice]).to eq('Successfully logged in')

        get expenses_path
        expect(response).to have_http_status(:ok)
      end
    end

    context 'with invalid credentials' do
      it 'renders the login form again with errors' do
        post user_sessions_path, params: { user_session: { username: user.username, password: 'wrong' } }

        expect(response).to have_http_status(:ok)
        expect(response.body).to include('id="errors"')
      end
    end
  end

  describe 'GET /logout' do
    it 'logs the user out and redirects to the login page' do
      post user_sessions_path, params: { user_session: { username: user.username, password: password } }
      get expenses_path
      expect(response).to have_http_status(:ok)

      get logout_path
      expect(response).to redirect_to(new_user_session_path)

      get expenses_path
      expect(response).to redirect_to(login_path)
    end
  end
end
