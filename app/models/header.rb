# frozen_string_literal: true

##
# Useful for creating default headers for views.
class Header
  ##
  # create instance variables for the action and controller.
  # The controller is the last part of the path.
  def initialize(params)
    @action = params[:action]
    @controller = params[:controller].split("/").last
  end

  ##
  # Example:
  # location_types => "Location Types" for the index action.
  # location_types => "New Location Type" if the action is new.
  def to_s
    return controller.gsub('_', ' ').titleize if action == "index"

    "#{action.capitalize} #{controller.singularize.gsub('_', ' ').titleize}"
  end

  ##
  # Example:
  # location_types => "location-types" if action is index.
  # location_types => "new-location-type" if action is new.
  def to_css_class
    return controller.gsub('_', '-') if action == "index"

    "#{action}-#{controller.singularize.gsub('_', '-')}"
  end

  private

  attr_reader :action, :controller
end
