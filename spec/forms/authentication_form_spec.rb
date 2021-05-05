# frozen_string_literal: true

require "rails_helper"

RSpec.describe AuthenticationForm, type: :model do
  # rubocop:disable Lint/ConstantDefinitionInBlock
  with_model :ModelC do
    table do |t|
      t.string :name
      t.timestamps null: false
    end

    model do
      include Auditable
      validates_presence_of :name
    end
  end
  before(:all) do
    class ModelCForm
      include AuthenticationForm

      set_attributes :name
    end
  end
  # rubocop:enable Lint/ConstantDefinitionInBlock

  let(:params) { ActionController::Parameters.new(controller: "controller", action: "action") }

  it "should create the record if the user is valid" do
    admin_swipe_card_id = generate(:swipe_card_id)
    create(:administrator, swipe_card_id: admin_swipe_card_id)
    model_c_form = ModelCForm.new
    expect {
      model_c_form.submit(params.merge(model_c: { name: "name", user_code: admin_swipe_card_id }))
    }.to change(ModelC, :count).by(1)
  end

  it "should not create the record if the user does not exist" do
    model_c_form = ModelCForm.new
    expect {
      model_c_form.submit(params.merge(model_c: { name: "name", user_code: "1111" }))
    }.to_not change(ModelC, :count)
    expect(model_c_form.errors.full_messages).to include("User #{I18n.t("errors.messages.existence")}")
  end

  # Refactor below

  it "should not create the record if the user (scientist) is not authorised" do
    sci_swipe_card_id = generate(:swipe_card_id)
    create(:scientist, swipe_card_id: sci_swipe_card_id)
    model_c_form = ModelCForm.new
    expect {
      model_c_form.submit(params.merge(model_c: { name: "name", user_code: sci_swipe_card_id }))
    }.to_not change(ModelC, :count)
    expect(model_c_form.errors.full_messages).to include("User #{I18n.t("errors.messages.authorised")}")
  end

  it "should not create the record if the user is inactive" do
    admin_swipe_card_id = generate(:swipe_card_id)
    user = create(:administrator, swipe_card_id: admin_swipe_card_id)
    user.deactivate
    model_c_form = ModelCForm.new
    expect {
      model_c_form.submit(params.merge(model_c: { name: "name", user_code: admin_swipe_card_id }))
    }.to_not change(ModelC, :count)
    expect(model_c_form.errors.full_messages).to include("User #{I18n.t("errors.messages.active")}")
  end
end
