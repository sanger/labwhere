# frozen_string_literal: true

##
# This will create a persisted scan.
# It can be used from a view or elsewhere.
class EmptyLocationForm
  include ActiveModel::Model

  attr_reader :current_user, :user_code, :controller, :action, :location_barcode, :location, :params

  validate :check_user, :check_location, :check_location_has_no_child_locations

  def initialize; end

  def form_name
    :empty_location_form
  end

  def submit(params)
    @params = params
    assign_params
    assign_attributes
    if valid?
      location.remove_all_labwares(current_user)
      true
    else
      false
    end
  end

  def assign_params
    @controller = params[:controller]
    @action = params[:action]
    @user_code = params[form_name][:user_code]
    @location_barcode = params[form_name].fetch(:location_barcode, '').strip
  end

  def assign_attributes
    self.current_user = user_code
    self.location = location_barcode
  end

  def current_user=(user_code)
    @current_user = User.find_by_code(user_code)
  end

  def location=(location_barcode)
    @location = Location.find_by(barcode: location_barcode)
  end

  private

  def check_user
    UserValidator.new.validate(self)
  end

  def check_location
    return if location.present?

    errors.add(:base, "Location with barcode #{location_barcode} does not exist")
  end

  def check_location_has_no_child_locations
    return if location.blank?
    return unless location.has_children?

    errors.add(:base, "Location with barcode #{location_barcode} has child locations")
  end
end
