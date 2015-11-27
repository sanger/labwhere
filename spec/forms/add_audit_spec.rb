require "rails_helper"

RSpec.describe AddAudit, type: :model do
  
  with_model :ModelE do
    table do |t|
      t.string :name
      t.timestamps null: false
    end

    model do
      include Auditable
    end
    
  end

  class ModelEForm
    include AuthenticationForm
    include AddAudit

    set_attributes :name

  end

  let!(:user) { create(:administrator)}

  it "should add an audit record" do
    params = ActionController::Parameters.new(controller: 'my_controller', action: 'create', model_e: {current_user: user.swipe_card_id, name: "aname"})
    model_e_form = ModelEForm.new
    model_e_form.submit(params)
    expect(model_e_form.model_e.audits.count).to eq(1)
    expect(model_e_form.model_e.audits.first.user).to eq(user)
  end
end