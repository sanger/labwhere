class ParentWhiteListValidator < ActiveModel::Validator
  def validate(record)
    unless record.parent.present? and record.parent.location_type.in?(options[:location_types])
      record.errors[:parent] << "must be one of the following types: #{options[:location_types].map(&:name).join(", ")}"
    end
  end
end
