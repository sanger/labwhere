require "rails_helper"

RSpec.describe AuditUser, type: :model do 

  class MyModel
    include ActiveModel::Model
    include AuditUser

    attr_accessor :name

    def initialize(attributes)
      @params = attributes
      @user = find_user(params[:user])
      @name = params[:name]
    end
  end

  let!(:user)                   { create(:user)}
  let(:controller_params)       { { controller: "my_model", action: "create"} }
  let(:params)                  { ActionController::Parameters.new(controller_params) }

  it "should not be valid if the user does not exist" do
    expect(MyModel.new(params)).to_not be_valid
  end

  it "should not be valid if the user is not authorised" do
    allow(user).to receive(:allow?).and_return(false)
    expect(MyModel.new(params.merge(user: user.swipe_card_id))).to_not be_valid
  end

  it "should be valid if the user is authorised" do
    allow_any_instance_of(User).to receive(:allow?).and_return(true)
    expect(MyModel.new(params.merge(user: user.swipe_card_id))).to be_valid
  end
end