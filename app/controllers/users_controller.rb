class UsersController < ApplicationController

  before_action :set_user, except: [:index, :new, :create]
  before_action :users, only: [:index]

  def index
  end

  def new
    @user = User.new
  end

  def create
     @user = User.new(user_params)
    if @user.save
      redirect_to users_path, notice: "User successfully created"
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @user.update_attributes(user_params)
      redirect_to users_path, notice: "User successfully updated"
    else
      render :edit
    end
  end

  def deactivate
    @user.deactivate
    redirect_to users_path, notice: "User successfully deactivated"
  end

  def activate
    @user.activate
    redirect_to users_path, notice: "User successfully activated"
  end

  def users
    @users ||= User.all
  end

  helper_method :users

private

  def user_params
    params.require(:user).permit(:login, :swipe_card, :barcode, :type)
  end

  def set_user
    @user = current_resource
  end

   def current_resource
    @current_resource ||= User.find(params[:id]) if params[:id]
  end

end
