class ContainerReservationValidator < ActiveModel::Validator
  def validate(record)
    if record.team.present? && !record.container?
      record.errors.add(:base, 'Only Locations which are containers can be reserved')
    end
  end
end
