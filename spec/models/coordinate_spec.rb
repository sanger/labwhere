require 'rails_helper'

RSpec.describe Coordinate, type: :model do
  it "is invalid without a name" do
    expect(build(:coordinate, name: nil)).to_not be_valid
  end

  it "#find_or_create_by_name should find or create a coordinate or do nothing if coordinate is nil" do
    coordinate = create(:coordinate)
    expect {
      Coordinate.find_or_create_by_name(build(:coordinate).name)
    }.to change(Coordinate, :count).by(1)
    expect(Coordinate.find_or_create_by_name(coordinate.name)).to eq(coordinate)
    expect(Coordinate.find_or_create_by_name(nil)).to be_nil
  end
end
