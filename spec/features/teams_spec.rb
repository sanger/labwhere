require "rails_helper"

RSpec.describe "Teams", type: :feature do

  it "Allows a user to create a new team" do
    team = build(:team)
    visit teams_path
    click_link "Add new team"
    expect{
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
    within("#team_#{team.id}") do
      click_link "Edit"
    end
    expect{
      fill_in "Name", with: new_team.name
      click_button "Update Team"
    }.to change {team.reload.name}.to(new_team.name)
    expect(page).to have_content("Team successfully updated")
  end

  it "Reports an error if user adds a team with invalid attributes" do
    existing_team = create(:team)
    team = build(:team)
    visit teams_path
    click_link "Add new team"
    expect{
      fill_in "Name", with: existing_team.name
      fill_in "Number", with: team.number
      click_button "Create Team"
    }.to_not change(Team, :count)
    expect(page).to have_content("error prohibited this record from being saved")
  end
end