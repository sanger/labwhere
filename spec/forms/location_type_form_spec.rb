# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LocationTypeForm, type: :model do
  let(:controller_params)       { { controller: 'location_type', action: 'destroy' } }
  let(:params)                  { ActionController::Parameters.new(controller_params) }
  let!(:administrator)          { create(:administrator) }

  it 'should only destroy a location type if there are no locations attached' do
    location_type = create(:location_type, name: 'Building')
    create(:location, location_type: location_type)
    location_type_form = LocationTypeForm.new(location_type)
    expect(location_type_form.destroy(params.merge(user_code: administrator.barcode))).to be_falsey
    expect(location_type_form.errors.full_messages).to include(I18n.t('errors.messages.location_type_in_use'))

    location_type = create(:location_type)
    location_type_form = LocationTypeForm.new(location_type)
    expect(location_type_form.destroy(params.merge(user_code: administrator.barcode))).to be_truthy
  end
end
