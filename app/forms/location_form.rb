##
# Form object for a Location
class LocationForm

  include AuthenticationForm
  include Auditor

  validate :only_same_team_can_release_location

  set_attributes :name, :location_type_id, :parent_id, :container, :status, :rows, :columns

  after_assigning_model_variables :transform_location, :set_team

  delegate :parent, :barcode, :parentage, :type, :coordinateable?, :reserved?, to: :location

  attr_writer :coordinateable, :reserve

  def coordinateable
    @coordinateable ||= coordinateable?
  end

  def reserve
    @reserve ||= reserved?
  end

private

  def transform_location
    @model = location.transform if location.new_record?
  end

  def set_team
    @model.team_id = reserve_param? ? current_user.team_id : nil
  end

  def only_same_team_can_release_location
    if @model.team_id_changed? && !reserve_param?
      unless @model.team_id_was === current_user.team_id
        errors.add(:base, I18n.t("errors.messages.location_release", team: @model.reload.team.name))
      end
    end
  end

  def reserve_param?
    params.fetch(:location).fetch(:reserve, "0") == "1"
  end

end