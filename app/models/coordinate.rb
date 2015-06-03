class Coordinate < ActiveRecord::Base

  validates :name, presence: true, uniqueness: true

  def self.find_or_create_by_name(name)
    find_or_create_by(name: name) unless name.nil?
  end
end
