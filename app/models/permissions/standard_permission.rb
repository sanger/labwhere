##
# Permissions for a Standard User
# Allowed to create a scan in the user interface and the api.
module Permissions
  class StandardPermission < BasePermission
    def initialize(user)
      super
      allow :scans, [:create]
      allow "api/scans", [:create]
    end
  end
end