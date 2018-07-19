class SessionsController < ApplicationController
  def new
    @user = User.new
  end

  def create
    user = User.find_by(email: params[:session][:email].downcase)
    if user && user.authenticate(params[:session][:password])
      log_in user
      puts session[:user_id].inspect
      redirect_to current_user
    else
      flash.now[:danger] = "Invalid email/password"
      render 'sessions/new'
    end
  end

  def destroy
    log_out
    redirect_to root_url
  end
end
