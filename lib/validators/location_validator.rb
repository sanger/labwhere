class LocationValidator < ActiveModel::Validator
  def validate(record)
    record.errors.add(:location, "must be a container") unless record.location.container?
    record.errors.add(:location, "must be active") unless record.location.active?
    NestedValidator.new({attributes: :location}).validate_each(record, :location, record.location)
  end  
end