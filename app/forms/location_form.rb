class LocationForm

  include Auditor

  set_attributes :name, :location_type_id, :parent_id, :container, :status

end