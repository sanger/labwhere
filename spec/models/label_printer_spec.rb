require "rails_helper"

RSpec.describe LabelPrinter, type: :model do 

  let!(:location)     { create(:location)}
  let!(:printer)      { create(:printer)}

  it "should add the uuid of the printer to the request_uri" do
    label_printer = LabelPrinter.new(printer.id, location.id)
    expect(label_printer.uri.request_uri).to include(printer.uuid)
  end
 
  it "should add the location attributes to the body of the request" do
    label_printer = LabelPrinter.new(printer.id, location.id)
    expect(label_printer.body).to eq(label_printer.to_json)
  end 

  it "if the printing is successful should return an appropriate message" do
    allow_any_instance_of(Net::HTTP).to receive(:request).and_return(Net::HTTPResponse.new(2.0, 200, "OK"))
    label_printer = LabelPrinter.new(printer.id, location.id)
    expect(label_printer.post).to be_truthy
    expect(label_printer.message).to eq(I18n.t("printing.success"))
  end

  it "if the printing is unsuccessful it should return an appropriate message" do
    allow_any_instance_of(Net::HTTP).
    to receive(:request).and_return(Net::HTTPResponse.new(2.0, 422, "Unprocessable Entity"))
    label_printer = LabelPrinter.new(printer.id, location.id)
    expect(label_printer.post).to be_falsey
    expect(label_printer.message).to eq(I18n.t("printing.failure"))
  end

  context "to_json" do

    subject(:label_printer) { LabelPrinter.new(printer.id, location.id).as_json}

    it "should produced a root node" do
      expect(label_printer.keys).to include("label_printer")
    end

    it "should include a header" do
      header = label_printer["label_printer"][:header_text]
      expect(header).to_not be_nil
      expect(header.keys).to include(:header_text1)
      expect(header.keys).to include(:header_text2)
    end

    it "should include a footer" do
      footer = label_printer["label_printer"][:footer_text]
      expect(footer).to_not be_nil
      expect(footer.keys).to include(:footer_text1)
      expect(footer.keys).to include(:footer_text2)
    end

    it "should include a template" do
      expect(label_printer["label_printer"][:labels].first[:template]).to eq("labwhere")
    end

    it "should include a plate with the barcode, location and parent location" do
      plate = label_printer["label_printer"][:labels].first[:plate]
      expect(plate[:barcode]).to eq(location.barcode)
      expect(plate[:location]).to eq(location.name)
      expect(plate[:parent_location]).to eq(location.parent.name)
    end
  end

end