##
# Form object for a Location
class LocationForm

  include AuthenticationForm
  include Auditor
  
  set_attributes :name, :location_type_id, :parent_id, :container, :status, :rows, :columns

  after_assigning_model_variables :transform_location

  delegate :parent, :barcode, :parentage, :type, :coordinateable?, to: :location

  attr_writer :coordinateable

  def coordinateable
    @coordinateable ||= coordinateable?
  end

private

  def transform_location
    @model = location.transform if location.new_record?
  end

end