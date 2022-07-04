# frozen_string_literal: true

class RestrictionCreator
  attr_reader :restrictions

  def initialize(restrictions)
    @restrictions = restrictions
  end

  def run!
    generate!
  end

  private

  def generate!
    restrictions.each do |_k, restriction|
      create_restriction(restriction)
    end
  end

  def create_restriction(restriction)
    type = restriction['type'] || 'Restriction'
    location_type = LocationType.find_or_create_by(name: restriction['location_type'])
    location_types_restrictions = restriction.delete('location_types_restrictions')
    new_restriction = type.constantize.create(restriction.merge('location_type' => location_type))
    return if location_types_restrictions.blank?

    create_location_types_restrictions(new_restriction,
                                       location_types_restrictions)
  end

  def create_location_types_restrictions(restriction, location_types_restrictions)
    location_types_restrictions.each do |location_type_name|
      location_type = LocationType.find_or_create_by(name: location_type_name)
      LocationTypesRestriction.create('location_type_id' => location_type.id, 'restriction_id' => restriction.id)
    end
  end
end
