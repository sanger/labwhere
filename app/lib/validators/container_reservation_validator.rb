# frozen_string_literal: true

# ContainerReservationValidator
class ContainerReservationValidator < ActiveModel::Validator
  def validate(record)
    return unless record.team.present? && !record.container?

    record.errors.add(:base, 'Only Locations which are containers can be reserved')
  end
end
