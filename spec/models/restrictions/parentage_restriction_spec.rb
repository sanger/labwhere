require 'rails_helper'

RSpec.describe ParentageRestriction, type: :model do

  let(:parentage_restriction) { create(:parentage_restriction) }

  it "returns location_types in the params" do
    expect(parentage_restriction.params).to include(:location_types)
  end

end