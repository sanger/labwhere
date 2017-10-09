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
      params.delete[:start_from]
      params.delete[:end_to]
      location.assign_attributes(params[:location])
      transform_location
      location.save if valid?
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
    return if (start_from.empty? and end_to.empty?) or (not start_from.empty? and not end_to.empty?)
    errors.add(:start_from, :blank, message: "must be present if End is present") if start_from.empty? 
    errors.add(:end_to, :blank, message: "must be present if Start is present") if end_to.empty? 
  end

  private

  def assign_attributes(params)
    @current_user = User.find_by_code(params[:user_code])
    @controller = params[:controller]
    @action = params[:action]
  end

  def add_location_errors
    location.errors.each do |key, value|
      errors.add key, value
    end
  end

  def transform_location
    @location = location.transform if location.new_record?
  end

  def generate_names(prefix, start_from, end_to, &block)
    if pos_int?(start_from) and pos_int?(end_to) and start_from.to_i < end_to.to_i
      (prefix + start_from..prefix + end_to).each do |name|
        yield name
      end
    end
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
