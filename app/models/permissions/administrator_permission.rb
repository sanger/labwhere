# frozen_string_literal: true

##
# Permissions for Admin User
# Allowed access to do anything
module Permissions
  class AdministratorPermission < BasePermission
    def initialize(user)
      super
      allow_all
    end
  end
end
