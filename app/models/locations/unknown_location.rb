class UnknownLocation < Location
  validates_with MaximumRecordsValidator, klass: UnknownLocation, limit: 1

  def self.get
    first || create(name: UNKNOWN)
  end

  def unknown?
    true
  end
end
