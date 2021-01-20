# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CoordinateForm, type: :model do
  let(:coordinate) { create(:coordinate) }
  let(:administrator) { create(:administrator) }
  let(:labware) { create(:labware) }

  let(:coordinate_form) { CoordinateForm.new(coordinate) }
  let(:controller_args) { { controller: "locations/coordinates", action: "update" } }
  let(:user_args) { { user_code: administrator.login } }
  let(:labware_args) { { labware_barcode: labware.barcode } }

  let(:param_args) { controller_args.merge(user_args).merge(labware_args) }
  let(:params) { ActionController::Parameters.new(coordinate: param_args) }

  context 'when user_code is not set' do
    let(:user_args) { {} }

    it 'is not valid' do
      result = coordinate_form.submit(params)
      expect(result).to be_falsey
      expect(coordinate_form).to_not be_valid
    end
  end

  context 'when labware_barcode is not set' do
    let(:labware_args) { {} }

    it 'is not valid without a labware barcode' do
      result = coordinate_form.submit(params)
      expect(result).to be_falsey
      expect(coordinate_form).to_not be_valid
    end
  end

  describe '#submit' do
    context 'when labware barcode is not nil' do
      it 'sets the labware\'s coordinate' do
        result = coordinate_form.submit(params)
        expect(result).to be_truthy
        expect(coordinate.reload.labware).to eq(labware)
      end

      it 'creates an audit' do
        expect { coordinate_form.submit(params) }.to change { Audit.count }.by(1)
      end
    end

    context 'when the labware barcode is nil' do
      let(:labware_args) { { labware_barcode: nil } }
      let(:labware_in_coordinate) { create(:labware) }

      before do
        coordinate.labware = labware_in_coordinate
      end

      it 'empties the coordinate' do
        result = coordinate_form.submit(params)
        expect(result).to be_truthy
        expect(coordinate.reload.labware).to be_instance_of(NullLabware)
        expect(labware_in_coordinate.coordinate_id).to be_nil
      end

      it 'creates an audit' do
        expect { coordinate_form.submit(params) }.to change { Audit.count }.by(1)
      end
    end
  end
end
