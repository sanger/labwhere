# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CoordinatesForm, type: :model do
  let(:technician) { create(:technician) }
  let(:coordinates) { create_list(:coordinate, 3) }
  let(:labwares) { create_list(:labware, 3) }
  let(:coordinates_form) { CoordinatesForm.new }

  let(:params) { ActionController::Parameters.new(param_args) }
  let(:param_args) { { controller: "api/coordinates", action: "update" }.merge(user_params).merge(coordinates_params) }
  let(:user_params) { { user_code: technician.login } }
  let(:coordinates_params) do
    { coordinates: coordinates.map.with_index { |c, i| { id: c.id, labware_barcode: labwares[i].barcode } } }
  end

  before do
    @result = coordinates_form.submit(params)
  end

  context 'when user_code is not set' do
    let(:user_params) { {} }

    it 'is invalid' do
      expect(@result).to be_falsey
      expect(coordinates_form).to_not be_valid
    end
  end

  context 'when a coordinate\'s location is reserved by another team' do
    let(:labwares) { create_list(:labware, 4) }
    let(:coordinates) do
      create_list(:coordinate, 3) << create(:coordinate, location: create(:location_with_parent, team: create(:team)))
    end

    it 'is invalid' do
      expect(@result).to be_falsey
      expect(coordinates_form).to_not be_valid
    end
  end

  describe '#submit' do
    context 'when all params are valid' do
      it 'returns true' do
        expect(@result).to be_truthy
      end

      it 'updates the coordinates' do
        coordinates.each.with_index { |c, i| expect(c.reload.labware).to eq(labwares[i]) }
      end

      it 'creates an audit record for each coordinate' do
        coordinates.each { |c| expect(c.audits).to_not be_empty }
      end
    end

    context 'when a param is not valid' do
      let(:coordinates_params) do
        {
          coordinates: coordinates.map.with_index { |c, i| { id: c.id, labware_barcode: labwares[i].barcode } }
                                  .push({ id: create(:coordinate) }) # Missing labware_barcode
        }
      end

      it 'returns false' do
        expect(@result).to be_falsey
      end

      it 'does not update any coordinates' do
        coordinates.each.with_index { |c, _i| expect(c.reload.labware).to be_instance_of(NullLabware) }
      end

      it 'does not create an audit records' do
        coordinates.each { |c| expect(c.audits).to be_empty }
      end
    end
  end
end
