module Permissions

  extend ActiveSupport::Concern

  included do
    delegate :allow?, to: :current_permissions
  end

  def self.permission_for(user)
    "Permissions::#{user.class}Permission".constantize.new(user)
  end

  def current_permissions
    @current_permissions ||= Permissions.permission_for(self)
  end

end