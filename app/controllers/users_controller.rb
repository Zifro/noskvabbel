class UsersController < ApplicationController
  
  # Displays a form for the user to edit his or her account
  def edit
    @user = current_user
  end
  
  # Updates the user attributes from what the user has provided in params
  def update
    
    @user = current_user
    
    if params[:user][:password]
      @user.password = params[:user][:password]
      @user.password_confirmation = params[:user][:password_confirmation]
    end
    @user.gender = params[:user][:gender]
    @user.username = params[:user][:username]
    
    if @user.save
      redirect_to :account, :notice => 'Your account has been successfully updated'
    else
      render :action => :edit
    end
    
  end
  
end
