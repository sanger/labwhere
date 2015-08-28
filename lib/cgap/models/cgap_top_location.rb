class CgapTopLocation < Cgap
  has_many :cgap_sub_locations

  validates_presence_of :barcode, :name
end