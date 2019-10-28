module StorageValidator
  extend ActiveSupport::Concern

  included do
    validate :check_location, :check_reservation
  end

  private

  def check_location
    LocationValidator.new.validate(self)
  end

  def check_reservation
    labwares.each do |barcode|
      next if barcode.nil?

      labware = Labware.find_or_initialize_by_barcode(barcode)
      next if labware.location.empty?

      check_location_for_reservation(labware.location)
    end
  end

  #  Check through all ancestors to make sure none are reserved
  def check_location_for_reservation(location)
    if location.reserved? && location.reserved_by != current_user.team
      errors.add(:location, I18n.t("errors.messages.reserved", team: location.reserved_by.name))
      return
    end
    check_location_for_reservation(location.parent) if location.parent_id?
  end
end
