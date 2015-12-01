require "rails_helper"

RSpec.describe LabelPrinterSerializer, type: :model do

  class TestLabels
    include ActiveModel::Serialization
    attr_reader :labels
    def initialize(labels)
      @labels = labels
    end
  end

  let!(:locations)  { create_list(:location_with_parent, 5)}
  let(:labels)      { TestLabels.new(locations)}
  let(:json)        { LabelPrinterSerializer.new(labels).as_json["label_printer"] }

  it "should have a root node" do
    expect(json).to_not be_nil
  end

  it "should have a header" do
    header = json[:header_text]
    expect(header).to_not be_nil
    expect(header.keys).to include(:header_text1)
    expect(header.keys).to include(:header_text2)
  end

  it "should have a footer" do
    footer = json[:footer_text]
    expect(footer).to_not be_nil
    expect(footer.keys).to include(:footer_text1)
    expect(footer.keys).to include(:footer_text2)
  end

  it "should have some labels" do
    expect(json[:labels].length).to eq(5)
  end

  it "each label should correspond to a location" do
    label = json[:labels].first
    expect(label[:template]).to eq("labwhere")
    expect(label[:plate][:barcode]).to eq(locations.first.barcode)
    expect(label[:plate][:location]).to eq(locations.first.name)
    expect(label[:plate][:parent_location]).to eq(locations.first.parent.name)
    expect(label[:plate][:id]).to be_nil
  end
  
 
end