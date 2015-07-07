##
# For two fields will check whether either one is completed
# These fields are signified by the options[:fields] attribute
class EitherOrValidator < ActiveModel::Validator
  def validate(record)
    fields = options[:fields]
    if fields.all? { |field| record.send(field).blank? }
      record.errors[:base] << "#{fields.collect { |field| field.to_s.humanize }.join(" or ")} must be completed"
    end
  end  
end