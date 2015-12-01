require "rails_helper"

RSpec.describe LabelPrinter, type: :model do 

  let!(:location)     { create(:location)}
  let!(:printer)      { create(:printer)}
  let!(:locations)    { create_list(:location, 5)}

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

  it "should print multiple labels" do
    label_printer = LabelPrinter.new(printer.id, locations.map(&:id))
    expect(label_printer.as_json["label_printer"][:labels].length).to eq(5)
  end

end