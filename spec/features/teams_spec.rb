# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Teams", type: :feature do
  let!(:admin_swipe_card_id) { generate(:swipe_card_id) }
  let!(:administrator) { create(:administrator, swipe_card_id: admin_swipe_card_id) }

  it "Allows a user to create a new team" do
    team = build(:team)
    visit teams_path
    click_link "Add new team"
    expect {
      fill_in "User swipe card id/barcode", with: admin_swipe_card_id
      fill_in "Name", with: team.name
      fill_in "Number", with: team.number
      click_button "Create Team"
    }.to change(Team, :count).by(1)
    expect(page).to have_content("Team successfully created")
  end

  it "Allows a user to edit an existing team" do
    team = create(:team)
    new_team = build(:team)
    visit teams_path
    find(:data_id, team.id).click_link "Edit"
    expect {
      fill_in "User swipe card id/barcode", with: admin_swipe_card_id
      fill_in "Name", with: new_team.name
      click_button "Update Team"
    }.to change { team.reload.name }.to(new_team.name)
    expect(page).to have_content("Team successfully updated")
  end

  it "Reports an error if user adds a team with invalid attributes" do
    existing_team = create(:team)
    team = build(:team)
    visit teams_path
    click_link "Add new team"
    expect {
      fill_in "User swipe card id/barcode", with: admin_swipe_card_id
      fill_in "Name", with: existing_team.name
      fill_in "Number", with: team.number
      click_button "Create Team"
    }.to_not change(Team, :count)
    expect(page).to have_content("error prohibited this record from being saved")
  end

  it "Does not allow an unauthorised user (technician) to modify teams" do
    tech_swipe_card_id = generate(:swipe_card_id)
    create(:technician, swipe_card_id: tech_swipe_card_id)
    team = build(:team)
    visit teams_path
    click_link "Add new team"
    expect {
      fill_in "User swipe card id/barcode", with: tech_swipe_card_id
      fill_in "Name", with: team.name
      fill_in "Number", with: team.number
      click_button "Create Team"
    }.to_not change(Team, :count)
    expect(page).to have_content("error prohibited this record from being saved")
    expect(page).to have_content("User is not authorised")
  end

  it "Does not allow an unauthorised user to modify teams" do
    sci_swipe_card_id = generate(:swipe_card_id)
    create(:scientist, swipe_card_id: sci_swipe_card_id)
    team = build(:team)
    visit teams_path
    click_link "Add new team"
    expect {
      fill_in "User swipe card id/barcode", with: sci_swipe_card_id
      fill_in "Name", with: team.name
      fill_in "Number", with: team.number
      click_button "Create Team"
    }.to_not change(Team, :count)
    expect(page).to have_content("error prohibited this record from being saved")
    expect(page).to have_content("User is not authorised")
  end

  describe "audits", js: true do
    it "allows a user to view associated audits for a team" do
      team = create(:team_with_audits)
      visit teams_path
      find(:data_id, team.id).find(:data_behavior, "drilldown").click
      expect(find(:data_id, team.id)).to have_css("article", count: 5)
    end
  end
end
