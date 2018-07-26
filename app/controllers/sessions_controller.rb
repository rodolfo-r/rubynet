class SessionsController < ApplicationController
  def new
    @user = User.new
  end

  def create
    @user = User.find_by(email: params[:session][:email].downcase)
    if @user && @user.authenticated?(:password, params[:session][:password])
      if @user.activated?
        log_in @user
        params[:session][:remember_me] == '1' ? remember(@user) : forget(@user)
        redirect_to @user
      else
        flash[:danger] = "Email verification pending"
        redirect_to root_url
      end
    else
      flash.now[:danger] = "Invalid email/password"
      render 'sessions/new'
    end
  end

  def destroy
    log_out(@current_user) if logged_in?
    redirect_to root_url
  end
end
