class LocationForm

  include Auditor

  set_attributes :name, :location_type_id, :parent_id, :container, :status

  attr_accessor :parent_barcode

  validate :check_parent_location
  delegate :parent, to: :location

  def submit(params)
    set_params_attributes(self.model_name.i18n_key, params)
    set_current_user
    model.attributes = params[self.model_name.i18n_key].slice(*model_attributes).permit!
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