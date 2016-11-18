## A special kind of restriction that requires a relationship with location_types
class ParentageRestriction < Restriction

  has_many :location_types_restrictions, foreign_key: "restriction_id", dependent: :delete_all
  has_many :location_types, through: :location_types_restrictions

  def params
    super.merge(location_types: location_types)
  end

end
