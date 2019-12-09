# frozen_string_literal: true

class OrderedLocationSerializer < LocationSerializer
  has_many :coordinates
end
