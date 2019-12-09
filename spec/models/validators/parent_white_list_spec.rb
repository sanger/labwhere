# frozen_string_literal: true

require "rails_helper"

RSpec.describe ParentWhiteListValidator, type: :model do
  let(:valid_parent_types) { create_list(:location_type, 3) }

  let(:validator) do
    ParentWhiteListValidator.new(location_types: valid_parent_types)
  end

  let(:model_with_valid_parent) do
    location_of_valid_type = create(:location, location_type: valid_parent_types.first)
    create(:location, parent: location_of_valid_type)
  end

  let(:model_with_invalid_parent) { create(:location_with_parent) }

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
