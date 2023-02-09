# frozen_string_literal: true

# An unknown location is the standard one added to locations which
# are used to identify labwhere which have been scanned out
class UnknownLocation < Location
  def self.get
    first || create(name: UNKNOWN)
  end

  def unknown?
    true
  end
end
