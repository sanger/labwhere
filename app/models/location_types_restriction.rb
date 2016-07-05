class LocationTypesRestriction < ActiveRecord::Base

  belongs_to :location_type
  belongs_to :parentage_restriction

end