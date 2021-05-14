# frozen_string_literal: true

# frozen_string_literal

class UserSessionsController < ApplicationController
  skip_before_action :verify_the_user_is_logged_in

  def new
    @user_session = UserSession.new
  end

  def create
    @user_session = UserSession.new(user_session_params)
    if @user_session.save
      flash[:notice] = t('successfully_logged_in')
      redirect_to expenses_path
    else
      render action: 'new'
    end
  end

  def destroy
    if current_user
      @user_session = UserSession.find
      @user_session.destroy
      flash[:error] = t('successfully_logged_out')
    end
    redirect_to new_user_session_path
  end

private

  def user_session_params
    params.require(:user_session).permit(:username, :password).to_h
  end
end
