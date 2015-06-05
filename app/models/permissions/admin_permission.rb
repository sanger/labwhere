##
# Permissions for Admin User
# Allowed access to do anything
module Permissions
  class AdminPermission < BasePermission

    def initialize(user)
      super
      allow_all
    end
  end
end