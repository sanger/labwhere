module Cgap
  require_relative 'cgap/base'
  require_relative 'cgap/load_data'
  require_relative 'cgap/create_location_types'
  require_relative 'cgap/labware'
  require_relative 'cgap/load_data'
  require_relative 'cgap/location'
  require_relative 'cgap/migrate_labwares'
  require_relative 'cgap/migrate_locations'
  require_relative 'cgap/migrate_top_level_locations'
  require_relative 'cgap/storage'

  def self.table_name_prefix
    'cgap_'
  end
end
