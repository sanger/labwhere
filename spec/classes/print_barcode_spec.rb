require "rails_helper"

RSpec.describe PrintBarcode, type: :model do 

  let!(:location)     { create(:location)}
  let!(:printer)      { create(:printer)}
  let(:response_body) { JSON.parse(File.read(File.join(Rails.root, "spec", "support", "data", "response.json")))}

  it "should add the uuid of the printer to the request_uri" do
    print_barcode = PrintBarcode.new(printer.id, location.id)
    expect(print_barcode.uri.request_uri).to include(printer.uuid)
  end
 
  it "should add the location attributes to the body of the request" do
    print_barcode = PrintBarcode.new(printer.id, location.id)
    expect(print_barcode.request.body).to eq(LabelPrinter.new(location).to_json)
  end 

  it "if the printing is successful should return an appropriate message" do
    response = Net::HTTPResponse.new(2.0, 200, "OK")
    response.body = response_body
    allow_any_instance_of(Net::HTTP).to receive(:request).and_return(response)
    print_barcode = PrintBarcode.new(printer.id, location.id)
    expect(print_barcode.post).to be_truthy
    expect(print_barcode.message).to eq(I18n.t("printing.success"))
  end

   it "if the printer is unavailable should return an appropriate message" do
    response = Net::HTTPResponse.new(2.0, 423, "OK")
    response.body = response_body
    allow_any_instance_of(Net::HTTP).to receive(:request).and_return(response)
    print_barcode = PrintBarcode.new(printer.id, location.id)
    expect(print_barcode.post).to be_falsey
    expect(print_barcode.message).to eq(I18n.t("printing.unavailable"))
  end

   it "if the printing is unsuccessful it should return an appropriate message" do
    response = Net::HTTPResponse.new(2.0, 500, "OK")
    response.body = response_body
    allow_any_instance_of(Net::HTTP).to receive(:request).and_return(response)
    print_barcode = PrintBarcode.new(printer.id, location.id)
    expect(print_barcode.post).to be_falsey
    expect(print_barcode.message).to eq(I18n.t("printing.failure"))
  end

end