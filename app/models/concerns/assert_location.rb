module AssertLocation

  extend ActiveSupport::Concern

  included do
    before_save :assert_location
  end

  def assert_location
    self.location = Location.unknown if location.nil?
  end
end