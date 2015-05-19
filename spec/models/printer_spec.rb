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
end
