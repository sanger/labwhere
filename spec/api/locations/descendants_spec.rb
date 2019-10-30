# frozen_string_literal: true

require 'rails_helper'

describe Api::Locations::DescendantsController, type: :request do
  describe '#index' do
    before do
      @parent = create(:location)
      children = create_list(:location_with_parent, 5, parent: @parent)
      @grandchildren = children.map { |child| create_list(:ordered_location, 5, parent: child) }.flatten
      @descendants = children + @grandchildren
    end

    it 'returns the descendants of a location' do
      get api_location_descendants_path(@parent.barcode)
      expect(response).to be_successful
      expect(ActiveSupport::JSON.decode(response.body).length).to eq(@descendants.length)
    end

    context 'when min_available_coordinates is specified' do
      it 'uses the AvailableCoordinatesQuery' do
        expect(AvailableCoordinatesQuery).to receive(:call).with(@descendants, "5").and_call_original
        get api_location_descendants_path(@parent.barcode), params: { min_available_coordinates: 5 }
        expect(ActiveSupport::JSON.decode(response.body).length).to eq(@grandchildren.length)
      end
    end
  end
end
