require 'rails_helper'

describe Api::Labwares::LocationsController, type: :request do
  describe '#create' do
    before :each do
      post api_labwares_locations_path, params: { barcodes: barcodes }
      @body = JSON.parse(response.body, symbolize_names: true)
    end

    context 'when barcodes is empty' do
      let(:barcodes) { [] }

      it 'is successful' do
        expect(response).to be_successful
      end

      it 'returns an empty Location list' do
        expect(@body[:locations]).to be_instance_of(Array)
      end
    end

    context 'when barcodes are provided' do
      let(:location) { create(:ordered_location_with_labwares, rows: 3, columns: 3) }
      let(:location_with_labware) { create(:unordered_location_with_labwares) }
      let(:labware) { create(:labware) }
      let(:barcodes) do
        barcodes = location.coordinates.map { |c| c.labware.barcode }
        barcodes | [labware.barcode] | location_with_labware.labwares.map { |lw| lw.barcode }
      end

      it 'is successful' do
        expect(response).to be_successful
      end

      it 'returns a Location list for Labware found in ordered locations' do
        location.coordinates.each do |coordinate|
          expect(@body[:locations]).to include(
            id: coordinate.location.id,
            labware_barcode: coordinate.labware.barcode,
            row: coordinate.row,
            column: coordinate.column
          )
        end
      end

      it 'returns a Location list for Labware found in unordered locations' do
        location_with_labware.labwares.each do |labware|
          expect(@body[:locations]).to include(
            id: labware.location_id,
            labware_barcode: labware.barcode,
            row: nil,
            column: nil
          )
        end
      end

      it 'does not include labware not found' do
        labware_barcodes = @body[:locations].map { |location| location[:labware_barcode] }
        expect(labware_barcodes).not_to include(labware.barcode)
      end
    end
  end
end
