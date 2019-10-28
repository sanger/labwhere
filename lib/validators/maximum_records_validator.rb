class MaximumRecordsValidator < ActiveModel::Validator
  def validate(record)
    fields = options[:fields]
    if options[:klass].all.count >= options[:limit]
      record.errors[:base] << "Can't have more than #{options[:limit]} #{options[:klass]}"
    end
  end
end
