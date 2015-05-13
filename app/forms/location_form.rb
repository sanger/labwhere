class LocationForm

  include AuditForm

  set_attributes :name, :location_type_id, :parent_id, :container, :status

end