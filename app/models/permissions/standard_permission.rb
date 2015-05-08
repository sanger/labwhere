module Permissions
  class StandardPermission < BasePermission
    def initialize(user)
      super
      allow :scans, [:create]
    end
  end
end