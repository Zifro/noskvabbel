# frozen_string_literal: true

class ApplicationController < ActionController::Base
  protect_from_forgery

  before_action :load_user_from_session, :verify_the_user_is_logged_in

  helper_method :current_user

protected

  def verify_the_user_is_logged_in
    redirect_to login_path, notice: 'Please login first' if @user_session.new_record?
  end

private

  def current_user_session
    return @current_user_session if defined?(@current_user_session)

    @current_user_session = UserSession.find
  end

  def current_user
    return @current_user if defined?(@current_user)

    @current_user = current_user_session&.record
  end

  def load_user_from_session
    @user_session = (current_user || UserSession.new)
  end
end
