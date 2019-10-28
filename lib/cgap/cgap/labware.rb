# frozen_string_literal: true

class Cgap::Labware < Cgap::Base
  belongs_to :cgap_location, class_name: "Cgap::Location", foreign_key: :cgap_location_id
end
