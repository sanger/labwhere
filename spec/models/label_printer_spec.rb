require "rails_helper"

RSpec.describe LabelPrinter, type: :model do
  let!(:location)     { create(:location) }
  let!(:printer)      { create(:printer) }
  let!(:locations)    { create_list(:location, 5) }

  it "if the printing is successful should return an appropriate message" do
    allow(PMB::PrintJob).to receive(:execute).and_return(true)
    label_printer = LabelPrinter.new(printer: printer.id, locations: location.id, label_template_id: 1, copies: 1)
    expect(label_printer.post).to be_truthy
    expect(label_printer.message).to eq(I18n.t("printing.success"))
  end

  it "if the printing is unsuccessful it should return an appropriate message" do
    allow(PMB::PrintJob).to receive(:execute).and_raise(JsonApiClient::Errors::ServerError.new(OpenStruct.new(status: 500)))
    label_printer = LabelPrinter.new(printer: printer.id, locations: location.id, label_template_id: 1, copies: 1)
    expect(label_printer.post).to be_falsey
    expect(label_printer.message).to eq(I18n.t("printing.failure"))
  end

  it "should print multiple labels" do
    label_printer = LabelPrinter.new(printer: printer.id, locations: locations.map(&:id), label_template_id: 1, copies: 1)
    expect(label_printer.labels.to_h[:body].length).to eq(5)
  end

  it "should print multiple copies" do
    label_printer = LabelPrinter.new(printer: printer.id, locations: locations.map(&:id), label_template_id: 1, copies: 2)
    expect(label_printer.labels.to_h[:body].length).to eq(10)
  end

  it "should not be valid without printer, label template id, locations" do
    expect(LabelPrinter.new(printer: printer.id, label_template_id: 1)).to_not be_valid
    expect(LabelPrinter.new(printer: printer.id, locations: location.id)).to_not be_valid
    expect(LabelPrinter.new(label_template_id: 1, locations: location.id)).to_not be_valid
  end
end
