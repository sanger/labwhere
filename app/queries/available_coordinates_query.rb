#
# Returns all locations with a minimum of the given number of available coordinates
class AvailableCoordinatesQuery

  def self.call(locations = Location.all, min_available_coordinates)
    locations.joins(%q{INNER JOIN coordinates ON coordinates.location_id = locations.id
                       LEFT OUTER JOIN labwares ON labwares.coordinate_id = coordinates.id})
      .where("labwares.coordinate_id is NULL")
      .group("locations.id")
      .having("COUNT(*) >= ?", min_available_coordinates.to_i)
  end

end
