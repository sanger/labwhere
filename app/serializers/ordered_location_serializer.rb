# frozen_string_literal: true

# Serialize for the OrderedLocation model
class OrderedLocationSerializer < LocationSerializer
  has_many :coordinates
end
