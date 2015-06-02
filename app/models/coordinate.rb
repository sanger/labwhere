class Coordinate < ActiveRecord::Base

  validates_presence_of :name

  def self.find_or_create_by_name(name)
    find_or_create_by(name: name) unless name.nil?
  end
end
