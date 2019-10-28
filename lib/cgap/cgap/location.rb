# frozen_string_literal: true

class Cgap::Location < Cgap::Base
  belongs_to :parent, class_name: "Cgap::Location"
  has_many :labwares, class_name: "Cgap::Labwares"

  validates_presence_of :name
end
