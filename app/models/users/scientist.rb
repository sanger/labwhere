# frozen_string_literal: true

##
# Standard user
# Access to create scans.
class Scientist < User
  include Permissions
end
