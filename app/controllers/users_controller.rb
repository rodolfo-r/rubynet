class UsersController < ApplicationController
  before_action :logged_in_user, only: [:edit, :update, :delete]
  before_action :correct_user, only: [:edit, :update, :delete]

  def index
    @users = User.where(activated: true).paginate(page: params[:page])
    User.all
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      @user.send_activation_email
      flash[:info] = "Please check your email to activate your account."
      redirect_to root_url
    else
      render 'new'
    end
  end

  def show
    @user = User.find_by(id: params[:id], activated: true)
    if @user
      redirect_to @user
    else
      redirect_to root_url
    end
  end

  def edit
  end

  def update
    if @user.update_attributes(user_params)
      flash[:success] = "Updated Profile"
      redirect_to @user
    else
      render 'edit'
    end
  end

  def delete
  end

  private
    def user_params
      params.require(:user).permit(:name, :email, :password, :password_confirmation)
    end

    def logged_in_user
      unless logged_in?
        flash[:danger] = "Please log in."
        redirect_to login_url
      end
    end

    def correct_user
      @user = User.find(params[:id]) 
      redirect_to(root_url) unless @user == current_user
    end
end
