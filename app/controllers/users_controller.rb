class UsersController < ApplicationController
  before_action :users, only: [:index]

  def index
  end

  def new
    @user = UserForm.new
  end

  def create
    @user = UserForm.new
    if @user.submit(params)
      redirect_to users_path, notice: "User successfully created"
    else
      render :new
    end
  end

  def edit
    @user = UserForm.new(current_resource)
  end

  def update
    @user = UserForm.new(current_resource)
    if @user.submit(params)
      redirect_to users_path, notice: "User successfully updated"
    else
      render :edit
    end
  end

  def deactivate
    @user = current_resource
    @user.deactivate
    redirect_to users_path, notice: "User successfully deactivated"
  end

  def activate
    @user = current_resource
    @user.activate
    redirect_to users_path, notice: "User successfully activated"
  end

  def users
    @users ||= User.all
  end

  helper_method :users

  private

  def current_resource
    @current_resource ||= User.find(params[:id]) if params[:id]
 end
end
