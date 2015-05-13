module AuditUser

  extend ActiveSupport::Concern

  included do 
    attr_accessor :user
    validate :check_user
  end

private

  attr_reader :params, :user

  def find_user(user)
    User.find_by_code(user) || Guest.new
  end

  def check_user
    errors.add :user, "does not exist" if user.guest?
    errors.add :user, "is not authorised" unless user.allow?(params[:controller], params[:action])
  end


end