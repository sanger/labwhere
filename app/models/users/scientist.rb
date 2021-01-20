# frozen_string_literal: true

## TODO: check below
# Scientist user
# Access to:
# scan
# coordinates
# upload
class Scientist < User
  include Permissions
end
