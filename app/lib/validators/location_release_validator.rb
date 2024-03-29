# frozen_string_literal: true

# LocationReleaseValidator
class LocationReleaseValidator < ActiveModel::Validator
  def validate(record)
    return unless record.model.team_id_changed? && (record.model.team_id_was != options[:team_id])

    record.errors.add(:base, I18n.t('errors.messages.location_release', team: record.model.reload.team.name))
  end
end
