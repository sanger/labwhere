##
# Form object for a Location
class LocationForm

  include ActiveModel::Model
  validate :check_user, :check_location, :check_range
  attr_reader :current_user, :controller, :action, :location, :start_from, :end_to

  def initialize(location = nil)
    @location = location || Location.new
  end

  def submit(params)
    assign_attributes(params)
    if valid?
      locations = create_locations(params)
      run_transaction do
        locations.each do |new_location|
          new_location.save
        end
      end
    end
  end

  def update(params)
    assign_attributes(params)
    if valid?
      location.save
      true
    else
      false
    end
  end

  def destroy(params)
    assign_attributes(params)
    return false unless valid?
    location.destroy
    if location.destroyed?
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
      errors.add(:end_to, :invalid, message: "must be greater than Start")
    end
  end

  private

  def assign_attributes(params)
    @current_user = User.find_by_code(params[:user_code])
    @controller = params[:controller]
    @action = params[:action]
    @start_from = params.fetch(:location, {}).fetch(:start_from, nil)
    @end_to = params.fetch(:location, {}).fetch(:end_to, nil)
    params.fetch(:location, {}).delete(:start_from)
    params.fetch(:location, {}).delete(:end_to)
    @location.assign_attributes(params.fetch(:location, {}))
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
    if /\A\d+\Z/.match(value.to_s)
      true
    else
      false
    end
  end

  def generate_names(prefix, start_from, end_to, &block)
    if not start_from.nil? and not end_to.nil?
      ("#{prefix} #{start_from}".."#{prefix} #{end_to}").each do |name|
        yield name
      end
    else
      yield prefix
    end
  end

  def create_locations(params)
    locations = []
    prefix = params[:location][:name]
    generate_names(prefix, start_from, end_to) do |name|
      params[:location][:name] = name
      @location = Location.new
      location.assign_attributes(params[:location])
      transform_location
      locations.push location
    end
    locations
  end

  def run_transaction(&block)
    begin
      ActiveRecord::Base.transaction do
        yield
      end
      true
    rescue
      false
    end
  end


end
