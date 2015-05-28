require 'rails_helper'

RSpec.describe Coordinate, type: :model do
   it "is invalid without a name" do
    expect(build(:coordinate, name: nil)).to_not be_valid
  end
end
