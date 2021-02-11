# frozen_string_literal: true

##
# Updates a collection of Coordinates and adds an audit record for them
class CoordinatesForm
  include ActiveModel::Model
  include ActiveModel::Serialization

  validate :check_user, :check_coordinate_reservation

  attr_accessor :controller, :action, :current_user
  attr_writer :coordinates

  delegate :to_json, to: :coordinates

  def submit(params)
    set_attributes_from_params(params)
    return false unless valid?

    begin
      ActiveRecord::Base.transaction do
        Coordinate.update(coordinate_ids, update_params)

        coordinates.each do |coordinate|
          coordinate.create_audit(current_user, AuditAction::UPDATE)
        end
      end
      true
    rescue
      false
    end
  end

  def coordinates
    @coordinates ||= Coordinate.find(coordinate_ids)
  end

  private

  attr_accessor :params

  def set_attributes_from_params(params)
    self.params = params
    self.current_user = find_current_user(params[:user_code])
    self.controller = params.fetch(:controller)
    self.action = params.fetch(:action)
  end

  def check_user
    UserValidator.new.validate(self)
  end

  def check_coordinate_reservation
    coordinates.each do |coordinate|
      check_location_for_reservation(coordinate.location)
    end
  end

  def check_location_for_reservation(location)
    if location.reserved? && location.reserved_by != current_user.team
      errors.add(:location, I18n.t("errors.messages.reserved", team: location.reserved_by.name))
      return
    end
    check_location_for_reservation(location.parent) if location.parent_id?
  end

  def find_current_user(user_code)
    User.find_by_code(user_code)
  end

  def permitted_params
    params.require(:coordinates).map do |p|
      p.permit(:id, :labware_barcode)
    end
  end

  def coordinate_ids
    permitted_params.pluck(:id)
  end

  def update_params
    permitted_params.map { |param| { labware: find_labware!(param["labware_barcode"]) } }
  end

  def find_labware!(barcode)
    Labware.find_or_create_by!(barcode: barcode) unless barcode.nil?
  end
end
