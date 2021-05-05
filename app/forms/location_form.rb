# frozen_string_literal: true

##
# Form object for a Location
class LocationForm
  include ActiveModel::Model
  include ActiveModel::Serialization

  validate :check_user, :check_location, :check_range, :only_same_team_can_release_location
  attr_reader :current_user, :controller, :action, :location, :start_from, :end_to

  # delegate_missing_to :location # rails 5
  delegate :parent, :internal_parent, :barcode, :parentage, :type, :coordinateable?, :reserved?, :reserved_by, to: :location
  delegate :id, :created_at, :updated_at, :to_json, to: :location
  delegate :name, :location_type_id, :parent_id, :container, :protected, :status, :rows, :columns, to: :location

  def initialize(location = nil)
    @location = location || Location.new
  end

  def submit(params)
    @params = params
    assign_attributes(params)
    if valid?
      locations = create_locations(params)
      run_transaction do
        locations.each do |new_location|
          @location = new_location
          check_location
          @location.save!
          @location.create_audit(current_user, AuditAction::CREATE)
        end
      end
    else
      false
    end
  end

  def update(params)
    @params = params
    assign_attributes(params)
    if valid?
      run_transaction do
        location.create_audit(current_user, AuditAction::UPDATE) if location.save
      end
    else
      false
    end
  end

  def destroy(params)
    @params = params
    @current_user = User.find_by_code(params[:user_code])
    # assign_attributes(params)
    return false unless valid?

    location.destroy
    if location.destroyed?
      location.create_audit(current_user, AuditAction::DESTROY)
      true
    else
      add_location_errors
      false
    end
  end

  def check_user
    UserValidator.new.validate(self)
  end

  def check_location
    return if location.valid?

    add_location_errors
  end

  def check_range
    if start_from.nil? and not end_to.nil?
      errors.add(:start_from, :blank, message: "must be present if End is present")
    elsif not start_from.nil? and end_to.nil?
      errors.add(:end_to, :blank, message: "must be present if Start is present")
    elsif pos_int?(start_from) and pos_int?(end_to) and start_from.to_i >= end_to.to_i
      errors.add(:start_from, :invalid, message: "must be less than End")
    end
  end

  def self.model_name
    ActiveModel::Name.new(Location)
  end

  def reserve
    @reserve ||= reserved?
  end

  def coordinateable
    @coordinateable ||= (coordinateable? || @location.is_a?(OrderedLocation))
  end

  def persisted?
    location.id?
  end

  def model
    @location
  end

  private

  def assign_attributes(params)
    @current_user = User.find_by_code(params[:location][:user_code])
    @controller = params[:controller]
    @action = params[:action]
    @start_from = params.fetch(:location, {}).fetch(:start_from, nil)
    @end_to = params.fetch(:location, {}).fetch(:end_to, nil)
    @location.assign_attributes(location_attrs(params))
    transform_location
    set_team
  end

  def location_attrs(params)
    params.fetch(:location, {}).except(:start_from, :end_to, :user_code, :reserve, :coordinateable)
  end

  def add_location_errors
    location.errors.each do |key, value|
      errors.add key, value
    end
  end

  def transform_location
    @location = location.transform if location.new_record?
  end

  def pos_int?(value)
    /\A\d+\Z/.match?(value.to_s)
  end

  def generate_names(prefix, start_from, end_to)
    if start_from.present? and end_to.present?
      (start_from..end_to).each do |name|
        yield "#{prefix} #{name}"
      end
    else
      yield prefix
    end
  end

  def create_locations(params)
    locations = []
    # Remove double spaces and any interloping unfriendly characters
    prefix = params[:location][:name].gsub(/\s+/, ' ').strip
    generate_names(prefix, start_from, end_to) do |name|
      params[:location][:name] = name
      @location = Location.new
      location.assign_attributes(location_attrs(params))
      transform_location
      set_team
      locations.push location
    end
    errors.add(:base, message: "Locations could not be created.") if locations.empty?
    locations
  end

  # rubocop:disable Style/ExplicitBlockArgument
  def run_transaction()
    begin
      ActiveRecord::Base.transaction do
        yield
      end
      true
    rescue
      false
    end
  end
  # rubocop:enable Style/ExplicitBlockArgument

  def set_team
    @location.team_id = reserve_param? ? current_user.team_id : nil
  end

  def only_same_team_can_release_location
    return unless @params.has_key? :location

    LocationReleaseValidator.new(team_id: current_user.team_id).validate(self) if !reserve_param?
  end

  def reserve_param?
    @params.fetch(:location).fetch(:reserve, "0") == "1"
  end
end
