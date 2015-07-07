##
# Form object for a Location
class LocationForm

  include Auditor

  set_attributes :name, :location_type_id, :parent_id, :container, :status

  attr_accessor :parent_barcode

  validate :check_parent_location
  delegate :parent, :barcode, :parentage, to: :location

  ##
  # A locations parent can be provided via a select or a barcode.
  # If the barcode is present we need to check whether it is a valid location.
  # The location barcode will always take precedence.
  # If the barcode is present and it is valid the parent will be added to the location.
  def submit(params)
    set_instance_variables(params)
    set_current_user(params)
    set_model_attributes(params)
    add_parent_location
    save_if_valid
  end

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

end