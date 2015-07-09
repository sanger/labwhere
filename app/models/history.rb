##
# Created specifically for Labware.
#
# Each time a Scan is created a history record will be created for each piece of associated Labware.
class History < ActiveRecord::Base
  belongs_to :scan
  belongs_to :labware

  ##
  # Create a summary message for the history record.
  # For example Scanned in to Location 123 by Doctor Who on 21 December 2099 at 08:40am
  def summary
    "Scanned in to #{scan.location.name} by #{scan.user.login} on #{created_at.to_s(:uk)}"
  end
end
