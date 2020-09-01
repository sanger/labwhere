# frozen_string_literal: true

##
# This will create a persisted scan.
# It can be used from a view or elsewhere.
class MoveLocationForm
  include ActiveModel::Model

  attr_reader :current_user, :user_code, :controller, :action, :parent_location_barcode, :child_location_barcodes, :parent_location, :child_locations, :params

  validate :check_user, :check_parent_location, :check_child_locations

  def initialize; end

  def form_name
    :move_location_form
  end

  def submit(params)
    @params = params
    assign_params
    assign_attributes
    if valid?
      parent_location.children = child_locations
      true
    else
      false
    end
  end

  def assign_params
    @controller = params[:controller]
    @action = params[:action]
    @user_code = params[form_name][:user_code]
    @parent_location_barcode =  params[form_name][:parent_location_barcode]
    @child_location_barcodes =  params[form_name][:child_location_barcodes]
  end

  def assign_attributes
    self.current_user = user_code
    self.parent_location = parent_location_barcode
    self.child_locations = child_location_barcodes
  end

  def current_user=(user_code)
    @current_user = User.find_by_code(user_code)
  end

  def parent_location=(parent_location_barcode)
    @parent_location = Location.find_by(barcode: parent_location_barcode)
  end

  def child_locations=(child_location_barcodes)
    @child_locations = (child_location_barcodes.split("\n") || []).collect(&:strip).collect { |barcode| Location.find_by(barcode: barcode) || barcode }
  end

  private

  def check_user
    UserValidator.new.validate(self)
  end

  def check_parent_location
    return if parent_location.present?

    errors.add(:parent_location, I18n.t("errors.messages.existence"))
  end

  def check_child_locations
    child_locations.each do |location|
      next if location.is_a?(Location)

      errors.add(:base, "Location with barcode #{location} #{I18n.t('errors.messages.existence')}")
    end
  end
end
