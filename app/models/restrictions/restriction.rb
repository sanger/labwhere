# frozen_string_literal: true

# # A restriction can be created with a validator and optional parameters
#  A restriction can be added to a LocationType
#  When a Location of that LocationType is created, each of the restrictions' validators are
#  passed to the Location through validates_with, along with the params

#  restriction = Restriction.new(validator: MyValidator, params: { starts_with: "X" })
#  location_type.restrictions << restriction
#  Location.create(name: "Fridge", location_type: location_type)

# MyValidator is run
class Restriction < ApplicationRecord
  belongs_to :location_type
  serialize :params, coder: JSON
  validates :validator, presence: true

  def params
    super || {}
  end

  def validator
    super.present? ? super.constantize : ''
  end
end
