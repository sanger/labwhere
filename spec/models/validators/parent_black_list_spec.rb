require "rails_helper"

RSpec.describe ParentBlackListValidator, type: :model do

  let(:invalid_parent_types) { create_list(:location_type, 3) }

  let(:validator) do
    ParentBlackListValidator.new(location_types: invalid_parent_types)
  end

  let(:model_with_valid_parent) do
    create(:location, parent: create(:location_with_parent))
  end

  let(:model_with_invalid_parent) do
    location_of_invalid_type = create(:location, location_type: invalid_parent_types.first)
    create(:location, parent: location_of_invalid_type)
  end

  let(:model_with_no_parent) { create(:location) }

  context 'when model has no parent' do
    it 'is valid' do
      validator.validate(model_with_no_parent)
      expect(model_with_no_parent.errors).to be_empty
    end
  end

  context 'when model parent has a permitted location type' do
    it 'is valid' do
      validator.validate(model_with_valid_parent)
      expect(model_with_valid_parent.errors).to be_empty
    end
  end

  context 'when model parent has a restricted location type' do
    it 'is invalid' do
      validator.validate(model_with_invalid_parent)
      expect(model_with_invalid_parent.errors).to_not be_empty
    end
  end

end