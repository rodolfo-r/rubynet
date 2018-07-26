class AccountActivationsController < ApplicationController
  def edit
    @user = User.find_by(email: params[:email])
    if @user && @user.authenticated?(:activation, params[:id])
      @user.activate
      redirect_to @user
    else
      flash[:danger] = "Invalid email/activation token"
      redirect_to root_url
    end
  end
end
