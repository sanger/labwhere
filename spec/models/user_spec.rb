# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  it "should not be valid without a login" do
    expect(build(:user, login: nil)).to_not be_valid
  end

  it "should be valid without a swipe card Id" do
    expect(build(:user, swipe_card_id: nil)).to be_valid
  end

  it "should allow blank or nil swipe card id" do
    create(:user, swipe_card_id: nil)
    expect(build(:user, swipe_card_id: nil)).to be_valid
  end

  it "should allow blank or nil barcode" do
    create(:user, barcode: nil)
    expect(build(:user, barcode: nil)).to be_valid
  end

  it "should be valid without a barcode" do
    expect(build(:user, barcode: nil)).to be_valid
  end

  it "should not be valid without a unique login" do
    user = create(:user)
    expect(build(:user, login: user.login)).to_not be_valid
  end

  it "should not be valid without a unique swipe card" do
    user = create(:user)
    expect(build(:user, swipe_card_id: user.swipe_card_id)).to_not be_valid
  end

  it "should not be valid without a unique barcode" do
    user = create(:user)
    expect(build(:user, barcode: user.barcode)).to_not be_valid
  end

  it "should not be valid without a team" do
    expect(build(:user, team: nil)).to_not be_valid
  end

  it "should not be valid without a swipe card id or barcode" do
    user = build(:user, swipe_card_id: nil, barcode: nil)
    expect(user).to_not be_valid
    expect(user.errors.full_messages).to include("Swipe card or Barcode must be completed")
  end

  describe "User Types" do
    it "should be able to create an Administrator" do
      user = create(:user, type: "Administrator")
      expect(Administrator.all.count).to eq(1)
    end

    it "should be able to create a Technician" do
      user = create(:user, type: "Technician")
      expect(Technician.all.count).to eq(1)
    end

    it "should be able to create a Guest" do
      user = create(:user, type: "Guest")
      expect(Guest.all.count).to eq(1)
    end

    it "should be able to create a Scientist" do
      user = create(:user, type: "Scientist")
      expect(Scientist.all.count).to eq(1)
    end
  end

  it "#find_by_code should be able to find user by swipe card id or barcode or login" do
    users = create_list(:user, 4)
    swipe_card_id = generate(:swipe_card_id)
    users.push(create(:user, swipe_card_id: swipe_card_id))
    user = build(:user)
    expect(User.find_by_code(swipe_card_id)).to eq(users.last)
    expect(User.find_by_code(users.first.barcode)).to eq(users.first)
    expect(User.find_by_code(users.first.login)).to eq(users.first)
    expect(User.find_by_code(user.swipe_card_id)).to be_guest
  end

  it "find_by_code should always return a guest user if code is empty" do
    user = create(:user, swipe_card_id: "")
    expect(User.find_by_code(nil)).to be_guest
    expect(User.find_by_code(user.swipe_card_id)).to be_guest
  end

  it "as_json should include correct attributes" do
    team = create(:team)
    user = create(:user, team: team)
    json = user.as_json
    expect(json["swipe_card_id"]).to be_nil
    expect(json["barcode"]).to be_nil
    expect(json["team_id"]).to be_nil
    expect(json["team"]).to eq(team.name)
    expect(json["created_at"]).to eq(user.created_at.to_s(:uk))
    expect(json["updated_at"]).to eq(user.updated_at.to_s(:uk))
  end

  it "should not update swipe_card_id and barcode if they are blank" do
    user = create(:user)
    user.update_attributes(swipe_card_id: nil, barcode: nil)
    expect(user.reload.swipe_card_id).to be_present
    expect(user.barcode).to be_present
  end

  it "can create an audit message" do
    create_action = AuditAction.new(AuditAction::CREATE)
    user = create(:user)
    audit = user.create_audit(create(:user))
    expect(audit.message).to eq(create_action.display_text)
  end
end
