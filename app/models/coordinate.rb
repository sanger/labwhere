##
# Each piece of Labware can have a specific co-ordinate
class Coordinate < ActiveRecord::Base

  validates :name, presence: true, uniqueness: true

  ##
  # Co-ordinates need to be unique
  # If it already exists return it otherwise create it
  def self.find_or_create_by_name(name)
    find_or_create_by(name: name) unless name.nil?
  end
end