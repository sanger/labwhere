require "rails_helper"

describe "BarcodeUtilities" do

  it "#join_barcodes will join a bunch of barcodes together with a newline character" do
    labwares = build_list(:labware, 5)
    barcodes = labwares.join_barcodes
    expect(barcodes.length).to eq(5)
    expect(labwares.all? { |labware| barcodes.include?(labware.barcode)}).to be_truthy
  end

  it "#join_barcodes will join a bunch of barcodes together with a specified character" do
    labwares = build_list(:labware, 5)
    expect(labwares.join_barcodes("\t").split("\t").length).to eq(5)
  end

  it "join barcodes will join a bunch of barcodes together in a relation" do
    create_list(:labware, 5)
    expect(Labware.all.join_barcodes.length).to eq(5)
  end
end