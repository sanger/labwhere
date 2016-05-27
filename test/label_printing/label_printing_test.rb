require "test_helper"

Dir[File.join(Rails.root,"lib","label_printing","*.rb")].each { |f| require f }

class LabelPrintingTest < ActiveSupport::TestCase

  attr_reader :location, :shelf_1, :shelf_2, :label_printing, :printer

  def setup
    @location = create(:unordered_location)
    @shelf_1 = create(:unordered_location_with_children, parent: location)
    @shelf_2 = create(:unordered_location_with_children, parent: location)
    @printer = create(:printer)
  end

  test "create the correct json" do
    @label_printing = LabelPrinting.new(printer.id, location.id)
    assert_equal 13, label_printing.json["label_printer"][:labels].length
  end

  test "should print the labels" do
    label_printing = LabelPrinting.new(printer.id, location.id)
    Net::HTTP.any_instance.stubs(:request).returns(Net::HTTPResponse.new(2.0, 200, "OK"))
    assert label_printing.run
  end

  test "should create the correct json for a subsection of the location" do
    @label_printing = LabelPrinting.new(printer.id, shelf_1.children.pluck(:id))
    assert_equal shelf_1.children.count, label_printing.json["label_printer"][:labels].length
  end

  def teardown
  end
end
