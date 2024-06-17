# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::LocationsController, type: :controller do
  describe '#info' do
    let(:location) { create(:location) }

    context 'when location exists' do
      before do
        allow(Location).to receive(:find_by).with(barcode: location.barcode).and_return(location)
        get :info, params: { barcode: location.barcode }
      end

      it 'returns the location info' do
        expect(response.body).to eq({ labwares: location.labwares.to_a, depth: location.max_descendant_depth }.to_json)
      end
    end

    context 'when location does not exist' do
      before do
        allow(Location).to receive(:find_by).with(barcode: 'nonexistent').and_return(nil)
        get :info, params: { barcode: 'nonexistent' }
      end

      it 'returns an error' do
        expect(response.body).to eq({ errors: ['Location not found'] }.to_json)
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end
