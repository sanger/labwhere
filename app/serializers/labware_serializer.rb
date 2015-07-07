##
# Serializer for the Labware
class LabwareSerializer < LocationLabwareSerializer

  has_one :location

end
