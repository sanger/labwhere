##
# Form object for a Location
class LocationForm
  include AuthenticationForm
  include Auditor

  validate :only_same_team_can_release_location

  set_attributes :name, :location_type_id, :parent_id, :container, :status, :rows, :columns

  after_assigning_model_variables :transform_location, :set_team

  delegate :parent, :barcode, :parentage, :type, :coordinateable?, :reserved?, :reserved_by, to: :location
  attr_writer :coordinateable, :reserve
  attr_reader :start_from, :end_to

  def coordinateable
    @coordinateable ||= coordinateable?
  end

  def reserve
    @reserve ||= reserved?
  end

  def destroy(params)
    self.form_variables.assign(self, params)
    return false unless valid?

    location.destroy
    if location.destroyed?
      true
    else
      add_errors
      false
    end
  end

  private

  def transform_location
    @model = location.transform if location.new_record?
  end

  def set_team
    @model.team_id = reserve_param? ? current_user.team_id : nil
  end

  def only_same_team_can_release_location
    return unless params.has_key? :location

    LocationReleaseValidator.new(team_id: current_user.team_id).validate(self) if !reserve_param?
  end

  def reserve_param?
    params.fetch(:location).fetch(:reserve, "0") == "1"
  end
end
