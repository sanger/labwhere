# frozen_string_literal: true

##
# Form object for creating or updating a User
require 'digest/sha1'

class UserForm
  include ActiveModel::Model
  include FormObject

  set_form_variables :user_code, current_user: :find_current_user

  delegate :login, :swipe_card_id, :barcode, :team_id, :type, :status, to: :user

  validate :check_user

  def initialize(user = nil)
    @user = user || User.new
  end

  def submit(params)
    @params = params
    assign_attributes

    ActiveRecord::Base.transaction do
      @params[:user][:swipe_card_id] = Digest::SHA1.hexdigest(@params[:user][:swipe_card_id]) if @params[:user][:swipe_card_id].present? && persisted?
      user.update(@params[:user].permit(:swipe_card_id, :barcode, :status, :team_id, :type, :login))
      if valid?
        user.create_audit(current_user)
        true
      else
        raise ActiveRecord::Rollback
      end
    end
  end

  def assign_attributes
    @user_code = @params[:user][:user_code]
    @current_user = find_current_user
    @controller = @params[:controller]
    @action = @params[:action]
  end

  def model
    @user
  end

  private

  def find_current_user
    User.find_by_code(user_code)
  end

  def check_user
    UserValidator.new.validate(self)
  end
end
