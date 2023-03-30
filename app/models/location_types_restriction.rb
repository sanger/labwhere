# frozen_string_literal: true

# LocationTypesRestriction
class LocationTypesRestriction < ApplicationRecord
  belongs_to :location_type
  belongs_to :parentage_restriction, foreign_key: :restriction_id
end
