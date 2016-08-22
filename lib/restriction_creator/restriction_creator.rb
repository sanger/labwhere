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
    restrictions.each do |k, restriction|
      create_restriction(restriction)
    end
    binding.pry
  end

  def create_restriction(restriction)
    Restriction.create(restriction.except("location_types_restrictions").merge("location_type": LocationType.find_by_name(restriction["location_type"])))
  end

  
end