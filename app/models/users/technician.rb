# frozen_string_literal: true

## TODO: check below
# Technician user
# Access to:
# scans
# coordinates
# move_locations
# empty_locations
# upload_labware
class Technician < User
  include Permissions
end
