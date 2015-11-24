##
# Form object for a Location
class LocationForm

  include AuthenticationForm

  set_attributes :name, :location_type_id, :parent_id, :container, :status, :rows, :columns

  set_form_variables :parent_barcode

  after_assigning_model_variables :transform_location, :add_parent_location

  validate :check_parent_location
  delegate :parent, :barcode, :parentage, :type, to: :location

private

  def check_parent_location
    return unless parent_barcode.present?
    ExistenceValidator.new({attributes: [:parent]}).validate_each(self, :parent, parent)
  end

  def add_parent_location
    return unless parent_barcode.present?
    return if parent_id.present? && parent.nil?
    location.parent = Location.find_by_code(parent_barcode)
  end

  def transform_location
    @model = location.transform if location.new_record?
  end

end