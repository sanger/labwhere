# frozen_string_literal: true

##
# Form object for creating or updating a User
require 'digest/sha1'

class UserForm
  include ActiveModel::Model
  include FormObject

  set_form_variables :user_code, current_user: :find_current_user

  validate :check_user

  delegate :becomes, to: :user

  def submit(params)
    @params = params
    assign_params
    @current_user = find_current_user

    case @params[:commit]
    when "Update User"
      update_user
    when "Create User"
      create_user
    else
      false
    end
  end

  def assign_params
    @swipe_card_id = params[:user][:swipe_card_id]
    @barcode = params[:user][:barcode]
    @user_code = params[:user][:user_code]
  end

  def update_user
    @user = model
    @params[:user][:swipe_card_id] = Digest::SHA1.hexdigest(@params[:user][:swipe_card_id]) if @params[:user][:swipe_card_id].present?
    user.update(@params[:user].permit(:swipe_card_id, :barcode, :status, :team_id, :type, :login))
    return false unless valid?

    user.create_audit(current_user)
    true
  end

  def create_user
    @user = User.new
    user.update(@params[:user].permit(:login, :swipe_card_id, :barcode, :team_id, :type, :status))
    return false unless valid?

    user.create_audit(current_user)
    true
  end

  private

  def find_current_user
    User.find_by_code(user_code)
  end

  def check_user
    UserValidator.new.validate(self)
  end
end
