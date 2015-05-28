class LocationProcessor

  include Auditor

  set_attributes :name, :location_type_id, :container, :status

  delegate :to_json, to: :location

  def submit(params)
    location.parent = Location.find_by(barcode: params[self.model_name.i18n_key][:parent_barcode])
    super
  end
end