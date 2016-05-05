require "rails_helper"

RSpec.describe LabelPrinter, type: :model do

  let!(:location)     { create(:location)}
  let!(:printer)      { create(:printer)}
  let!(:locations)    { create_list(:location, 5)}

  it "if the printing is successful should return an appropriate message" do
    allow(PMB::PrintJob).to receive(:execute).and_return(true)
    label_printer = LabelPrinter.new(printer.id, location.id)
    expect(label_printer.post).to be_truthy
    expect(label_printer.message).to eq(I18n.t("printing.success"))
  end

  it "if the printing is unsuccessful it should return an appropriate message" do
    allow(PMB::PrintJob).to receive(:execute).and_raise(JsonApiClient::Errors::ServerError.new({}))
    label_printer = LabelPrinter.new(printer.id, location.id)
    expect(label_printer.post).to be_falsey
    expect(label_printer.message).to eq(I18n.t("printing.failure"))
  end

  it "should print multiple labels" do
    label_printer = LabelPrinter.new(printer.id, locations.map(&:id))
    expect(label_printer.labels.to_h[:body].length).to eq(5)
  end

end