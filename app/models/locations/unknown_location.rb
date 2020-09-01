# frozen_string_literal: true

class UnknownLocation < Location
  def self.get
    first || create(name: UNKNOWN)
  end

  def unknown?
    true
  end
end
