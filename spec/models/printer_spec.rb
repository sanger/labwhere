require 'rails_helper'

RSpec.describe Printer, type: :model do
   it "is invalid without a name" do
    expect(build(:printer, name: nil)).to_not be_valid
  end

  it "is invalid without a uuid" do
    expect(build(:printer, uuid: nil)).to_not be_valid
  end

  it "is invalid without a unique name" do
    printer = create(:printer, name: "Unique Name")
    expect(build(:printer, name: printer.name)).to_not be_valid
  end

  it "#as_json should return the correct attributes" do
    printer = create(:printer)
    json = printer.as_json
    expect(json["audits_count"]).to be_nil
    expect(json["created_at"]).to eq(printer.created_at.to_s(:uk))
    expect(json["updated_at"]).to eq(printer.updated_at.to_s(:uk))
  end
end
