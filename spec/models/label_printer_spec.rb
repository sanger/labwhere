require "rails_helper"

RSpec.describe LabelPrinter, type: :model do

  let!(:location) { create(:location)}

  context "to_json" do

    subject(:label_printer) { LabelPrinter.new(location)}

    it "should produced a root node" do
      expect(label_printer.as_json.keys).to include("label_printer")
    end

    it "should include a header" do
      header = label_printer.as_json["label_printer"][:header_text]
      expect(header).to_not be_nil
      expect(header.keys).to include(:header_text1)
      expect(header.keys).to include(:header_text2)
    end

    it "should include a footer" do
      footer = label_printer.as_json["label_printer"][:footer_text]
      expect(footer).to_not be_nil
      expect(footer.keys).to include(:footer_text1)
      expect(footer.keys).to include(:footer_text2)
    end

    it "should include a template" do
      expect(label_printer.as_json["label_printer"][:labels].first[:template]).to eq("labwhere")
    end

    it "should include a plate with the barcode, location and parent location" do
      plate = label_printer.as_json["label_printer"][:labels].first[:plate]
      expect(plate[:barcode]).to eq(location.barcode)
      expect(plate[:location]).to eq(location.name)
      expect(plate[:parent_location]).to eq(location.parent.name)
    end
  end
  
end