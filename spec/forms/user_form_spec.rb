# frozen_string_literal: true

require "rails_helper"
require 'digest/sha1'

RSpec.describe UserForm, type: :model do
  let!(:sci_swipe_card_id) { generate(:swipe_card_id) }
  let!(:scientist) { create(:scientist, swipe_card_id: sci_swipe_card_id) }
  let!(:tech_swipe_card_id) { generate(:swipe_card_id) }
  let!(:technician) { create(:technician, swipe_card_id: tech_swipe_card_id, team_id: 2) }
  let!(:admin_swipe_card_id) { generate(:swipe_card_id) }
  let!(:administrator) { create(:administrator, swipe_card_id: admin_swipe_card_id) }
  let(:params) { ActionController::Parameters.new(controller: "users", action: "update") }

  describe "When editing a user" do
    let(:subject) { UserForm.new(technician) }

    it "if user is unauthorised (scientist) then swipe card id should not be updated" do
      expect {
        subject.submit(params.merge(user: { swipe_card_id: '12345', user_code: sci_swipe_card_id }))
      }.to_not change { technician.reload.swipe_card_id }
      expect(subject.errors.full_messages).to include("User is not authorised")
    end

    it "if user is scientist then they can edit themselves" do
      expect {
        UserForm.new(scientist).submit(params.merge(user: { swipe_card_id: '12345', user_code: sci_swipe_card_id }))
      }.to change { scientist.reload.swipe_card_id }
    end

    it "if user is scientist then they can edit themselves but not change their type" do
      scientist_form = UserForm.new(scientist)
      expect {
        scientist_form.submit(params.merge(user: { type: "Administrator", user_code: sci_swipe_card_id }))
      }.to_not change { scientist.reload.type }
      expect(scientist_form.errors.full_messages).to include("User is not authorised")
    end

    it "if user is authorised and swipe card is valid it should be updated" do
      expect {
        subject.submit(params.merge(user: { swipe_card_id: '12345', user_code: admin_swipe_card_id }))
      }.to change { technician.reload.swipe_card_id }.to(Digest::SHA1.hexdigest('12345'))
    end

    it "if user is authorised but swipe card id is left blank then swipe card id should not be updated" do
      expect {
        subject.submit(params.merge(user: { swipe_card_id: nil, user_code: admin_swipe_card_id }))
      }.to_not change { technician.reload.swipe_card_id }
    end

    it "if user is authorised but barcode is left blank then barcode should not be updated" do
      expect {
        subject.submit(params.merge(user: { barcode: nil, user_code: admin_swipe_card_id }))
      }.to_not change { technician.reload.barcode }
    end

    it "if user is authorised they should be able to update a users team" do
      expect {
        subject.submit(params.merge(user: { team_id: 1, user_code: admin_swipe_card_id }))
      }.to change { technician.reload.team_id }.to(1)
    end

    it "if no values are entered a user should not change" do
      expect {
        subject.submit(params.merge(user: { user_code: admin_swipe_card_id }))
      }.to_not change { technician.reload }
    end

    it "if user is technician they should be able to update a non-admin user" do
      expect {
        subject.submit(params.merge(user: { team_id: 1, user_code: tech_swipe_card_id }))
      }.to change { technician.reload.team_id }.to(1)
    end

    it "if user is technician they should not be able to update an admin user" do
      admin = UserForm.new(administrator)
      admin.submit(params.merge(user: { user_code: tech_swipe_card_id }))
      expect(admin.errors.full_messages).to include("User is not authorised")
    end

    it "if user is technician they should not be able to update an admin user's type" do
      admin = UserForm.new(administrator)
      admin.submit(params.merge(user: { user_code: tech_swipe_card_id, type: "Technician" }))
      expect(admin.errors.full_messages).to include("User is not authorised")
    end

    it "if user is technician they should not be able to make users an admin user" do
      new_user = UserForm.new
      new_user.submit(params.merge(user: { type: "Administrator", user_code: tech_swipe_card_id }))
    end
  end

  describe "When creating a user" do
    let(:subject) { UserForm.new }

    it "if user is authorised and fields are valid it should create a new User" do
      expect {
        subject.submit(params.merge(user: { user_code: tech_swipe_card_id, login: "swipe", swipe_card_id: "swipe", team_id: 1, type: "Technician", status: "active" }))
      }.to change(User, :count)
    end

    it "if user does not exist and fields are valid it should not create a new User" do
      expect {
        subject.submit(params.merge(user: { user_code: "", login: "swipe", swipe_card_id: "123", team_id: 1, type: "Technician", status: "active" }))
      }.to_not change(User, :count)
      expect(subject.errors.full_messages).to include("User does not exist")
    end

    it "if swipe card id is left blank it will error" do
      subject.submit(params.merge(user: { user_code: tech_swipe_card_id, login: "swipe", swipe_card_id: "", team_id: 1, type: "Technician", status: "active" }))
      expect(subject.errors.full_messages).to include("Swipe card or Barcode must be completed")
    end

    it "if login is left blank it will error" do
      subject.submit(params.merge(user: { user_code: tech_swipe_card_id, login: "", swipe_card_id: "swipe", team_id: 1, type: "Technician", status: "active" }))
      expect(subject.errors.full_messages).to include("Login can't be blank")
    end
  end
end
