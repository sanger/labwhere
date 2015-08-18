##
# Permissions for a guest user.
# Doesn't allow anything.
module Permissions
  class GuestPermission < BasePermission
    def initialize(user)
      super
    end
  end
end