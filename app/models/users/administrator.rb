##
# Inherits from User.
# Includes Permissions.
# An Admin user will have permissions to do anythin in the system.
class Administrator < User
  include Permissions
end
