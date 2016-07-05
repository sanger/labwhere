require 'rails_helper'

RSpec.describe Restriction, type: :model do

  it "is not valid without a validator" do
    expect(build(:restriction, validator: nil)).to be_invalid
  end

  it "returns validator as a constant" do
    expect(build(:restriction).validator).to be_kind_of(Class)
  end

  context "when params is empty" do
    it "returns a hash" do
      expect(build(:restriction).params).to eql({})
    end
  end

end