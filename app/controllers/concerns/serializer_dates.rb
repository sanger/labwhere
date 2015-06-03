module SerializerDates

  extend ActiveSupport::Concern
 
  included do 
    attributes :created_at, :updated_at
  end

  def created_at
    object.created_at.to_s(:uk)
  end

  def updated_at
    object.updated_at.to_s(:uk)
  end
end