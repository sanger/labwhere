class CgapLocation < Cgap

  belongs_to :parent, class_name: "CgapLocation"
  has_many :labwares, class_name: "CgapLabwares"

  validates_presence_of :name
end