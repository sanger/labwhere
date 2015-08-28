class CgapSubLocation < Cgap
  belongs_to :cgap_top_location
  has_many :cgap_labwares

  validates_presence_of :name, :cgap_top_location_id
end