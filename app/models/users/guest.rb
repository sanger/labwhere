# frozen_string_literal: true

##
# A Guest is a user that doesn't exist useful for authentication.
#
# Saves checking for nil objects.
#
# A Guest has no permissions.
#
# It inherits from ActiveRecord purely for assignment purposes. A record will never be saved.
#
# Most of the important methods are overriden.
class Guest < User
  include Permissions

  ##
  # Always set to 0
  def swipe_card_id
    "Guest"
  end

  ##
  # Always set to "Guest:1"
  def barcode
    "Guest:1"
  end

  ##
  # Always set to "Guest"
  def login
    "Guest"
  end

  ##
  # Always set to 1
  def team_id
    1
  end
end
