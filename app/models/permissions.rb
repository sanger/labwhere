##
# When a user is loaded so are their permissions.
# These will determine whether the user can scan or create and edit resources.
module Permissions

  extend ActiveSupport::Concern

  included do
    delegate :allow?, to: :current_permissions
  end

  ##
  # Create a new permission object
  # determined by the type of user
  def self.permission_for(user)
    "Permissions::#{user.class}Permission".constantize.new(user)
  end

  ##
  # Will return the current permissions or create a new Permissions object
  def current_permissions
    @current_permissions ||= Permissions.permission_for(self)
  end

end