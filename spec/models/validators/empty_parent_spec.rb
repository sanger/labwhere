# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EmptyParentValidator, type: :model do
  let(:validator) { EmptyParentValidator.new }
  let(:location_with_parent) { create(:location_with_parent) }
  let(:location) { create(:location) }

  context 'when model has no parent' do
    it 'is valid' do
      validator.validate(location)
      expect(location.errors).to be_empty
    end
  end

  context 'when model has a parent' do
    it 'is invalid' do
      validator.validate(location_with_parent)
      expect(location_with_parent).to_not be_empty
    end
  end
end
