# frozen_string_literal: true

require "rails_helper"

RSpec.describe Auditor, type: :model do
  # rubocop:disable Lint/ConstantDefinitionInBlock
  with_model :ModelE do
    table do |t|
      t.string :name
      t.timestamps null: false
    end

    model do
      include Auditable
    end
  end

  before(:all) do
    class ModelEForm
      include AuthenticationForm
      include Auditor

      set_attributes :name
    end
  end
  # rubocop:enable Lint/ConstantDefinitionInBlock

  let!(:administrator) { create(:administrator) }

  it "should add an audit record" do
    params = ActionController::Parameters.new(controller: 'my_controller', action: 'create', model_e: { user_code: administrator.swipe_card_id, name: "aname" })
    model_e_form = ModelEForm.new
    model_e_form.submit(params)
    expect(model_e_form.model_e.audits.count).to eq(1)
    expect(model_e_form.model_e.audits.first.user).to eq(administrator)
  end
end
