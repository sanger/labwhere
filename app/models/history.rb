class History < ActiveRecord::Base
  belongs_to :scan
  belongs_to :labware, counter_cache: true
end
