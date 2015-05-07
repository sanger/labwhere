class LocationForm

  include ActiveModel::Model

  ATTRIBUTES = [:name, :location_type_id, :parent_id, :container, :status]

  attr_reader :location 
  delegate *ATTRIBUTES, to: :location

  validate :check_for_errors

  def persisted?
    false
  end

  def self.model_name
    ActiveModel::Name.new(self, nil, "Location")
  end

  def initialize
  end

  def submit(params)
    location.attributes = params.slice(*ATTRIBUTES).permit!
    if valid?
      location.save
    else
      false
    end
  end

  def location
    @location ||= Location.new
  end

private

  def check_for_errors
    unless location.valid?
      location.errors.each do |key, value|
        errors.add key, value
      end
    end
  end

end