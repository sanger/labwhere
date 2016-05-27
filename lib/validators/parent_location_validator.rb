class ParentLocationValidator < ActiveModel::Validator
  def validate(record)
    if record.location_type.present?
      if LocationType.not_building?(record.location_type) and LocationType.not_site?(record.location_type) and record.parent.empty?
        record.errors[:parent] << "can only be blank for buildings"
      end
    end
  end
end