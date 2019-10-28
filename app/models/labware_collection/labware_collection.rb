# frozen_string_literal: true

module LabwareCollection
  def self.open(attributes = {})
    if attributes[:location].ordered?
      LabwareCollection::OrderedLocation.new(attributes)
    else
      LabwareCollection::UnorderedLocation.new(attributes)
    end
  end
end
