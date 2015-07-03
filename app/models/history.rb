##
# Created specifically for Labware.
#
# Each time a Scan is created a history record will be created for each piece of associated Labware.
class History < ActiveRecord::Base
  belongs_to :scan
  belongs_to :labware, counter_cache: true

  def summary
    "Scanned in to #{scan.location.name} by #{scan.user.login} on #{created_at.to_s(:uk)}"
  end
end
