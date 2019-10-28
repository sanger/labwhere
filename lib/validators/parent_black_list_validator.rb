class ParentBlackListValidator < ActiveModel::Validator
  def validate(record)
    if record.parent.present? and record.parent.location_type.in?(options[:location_types])
      record.errors[:parent] << "can not be any of the following types: #{options[:location_types].map(&:name).join(", ")}"
    end
  end
end
