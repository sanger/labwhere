class LocationReleaseValidator < ActiveModel::Validator
  def validate(record)
    if record.model.team_id_changed?
      unless record.model.team_id_was === options[:team_id]
        record.errors.add(:base, I18n.t("errors.messages.location_release", team: record.model.reload.team.name))
      end
    end
  end
end
