##
# A lot of the serializers include created_at and updated_at
# This minor concern provides a general way to deal with those dates.
module SerializerDates
  extend ActiveSupport::Concern

  included do
    attributes :created_at, :updated_at
  end

  ##
  # Output created_at as day month year time
  def created_at
    object.created_at.to_s(:uk)
  end

  ##
  # Output updated_at as day month year time
  def updated_at
    object.updated_at.to_s(:uk)
  end
end
