module Permissions
  class AdminPermission < BasePermission

    def initialize(user)
      super
      allow_all
    end
  end
end