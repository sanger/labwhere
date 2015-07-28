 class NullCoordinate
    def name
      "null"
    end

    def location
      Location.unknown
    end

    def empty?
      true
    end
  end