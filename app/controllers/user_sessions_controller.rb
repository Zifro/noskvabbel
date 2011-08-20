class UserSessionsController < ApplicationController

  skip_before_filter :verify_the_user_is_logged_in

  def new
    @user_session = UserSession.new
  end

  def create
    @user_session = UserSession.new(params[:user_session])
    if @user_session.save
        flash[:notice] = 'Successfully logged in'
        redirect_to expenses_path
      else
        render :action => "new"
    end
  end

  def destroy
    if current_user
      @user_session = UserSession.find
      @user_session.destroy
      flash[:notice] = 'Successfully logged out'
    end
    redirect_to new_user_session_path
  end
end