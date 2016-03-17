class LabelPrinting

  def initialize(printer, location_ids)
    @locations = location_ids.instance_of?(Array) ? location_ids : find_locations(location_ids).map(&:id)
    @label_printer = LabelPrinter.new(printer, @locations)
  end

  def json
    @label_printer.as_json
  end

  def run
    @label_printer.post
  end
  
private

  def find_locations(location_id)
    add_locations Location.find(location_id)
  end

  def add_locations(location)
    [].tap do |l|
      l << location
      location.children.each do |child|
        l << add_locations(child)
      end
    end.flatten.compact
  end
end