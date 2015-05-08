class LocationForm

  include ActiveModel::Model

  ATTRIBUTES = [:name, :location_type_id, :parent_id, :container, :status]

  attr_reader :location 
  delegate *ATTRIBUTES, to: :location

  validate :check_for_errors
  validate :check_user

  def persisted?
    location.id
  end

  def self.model_name
    ActiveModel::Name.new(self, nil, "Location")
  end

  def initialize(location = nil)
    @location = location || Location.new
  end

  def submit(params)
    @params = params
    @user = find_user(params[:user])
    location.attributes = params.slice(*ATTRIBUTES).permit!
    if valid?
      location.save
    else
      false
    end
  end

private

  attr_reader :user, :params

  def find_user(user)
    User.find_by_code(user) || Guest.new
  end

  def check_for_errors
    unless location.valid?
      location.errors.each do |key, value|
        errors.add key, value
      end
    end
  end

  def check_user
    errors.add :user, "does not exist" if user.guest?
    errors.add :user, "is not authorised" unless user.allow?(params[:controller], params[:action])
  end

end