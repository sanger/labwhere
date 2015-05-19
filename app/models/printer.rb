class Printer < ActiveRecord::Base

  validates_presence_of :name, :uuid
  validates_uniqueness_of :name
end
