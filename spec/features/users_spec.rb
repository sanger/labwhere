#(l4) As an admin I want to be able to create new users in the system and edit them in order to allow users to be tracked in the system.
require "rails_helper"

RSpec.describe "Users", type: :feature do

  let!(:teams) { create_list(:team, 2)}
  let!(:admin_user) { create(:admin)}

  it "Allows a user to create a new user" do
    user = build(:user)
    visit users_path
    click_link "Add new user"
    expect {
      fill_in "User swipe card id/barcode", with: admin_user.swipe_card_id
      fill_in "Login", with: user.login
      fill_in "Swipe card", with: user.swipe_card_id
      fill_in "Barcode", with: user.barcode
      select teams.first.name, from: "Team"
      click_button "Create User"
    }.to change(User, :count).by(1)
    expect(page).to have_content("User successfully created")
  end

  it "Allows a user to edit an existing user" do
    user = create(:user)
    user_2 = build(:user)
    visit users_path
    within("#user_#{user.id}") do
      click_link "Edit"
    end
    expect {
      fill_in "User swipe card id/barcode", with: admin_user.swipe_card_id
      fill_in "Swipe card", with: user_2.swipe_card_id
      click_button "Update User"
    }.to change { user.reload.swipe_card_id}.to(user_2.swipe_card_id)
  end

  it "Allows a user to create a different type of user" do
    user = build(:user)
    visit users_path
    click_link "Add new user"
    expect {
      fill_in "User swipe card id/barcode", with: admin_user.swipe_card_id
      fill_in "Login", with: user.login
      fill_in "Swipe card", with: user.swipe_card_id
      fill_in "Barcode", with: user.barcode
      select teams.first.name, from: "Team"
      select "Admin", from: "Type"
      click_button "Create User"
    }.to change(Admin, :count).by(1)
    expect(page).to have_content("User successfully created")
  end

  it "Allows a user to be deactivated" do
    user = create(:user)
    visit users_path
    within("#user_#{user.id}") do
      click_link "Edit"
    end
    expect {
      fill_in "User swipe card id/barcode", with: admin_user.swipe_card_id
      uncheck "Active"
      click_button "Update User"
    }.to change{user.reload.active?}.from(true).to(false)
    expect(page).to have_content("User successfully updated")
  end

  it "Allows a user to be activated" do
    user = create(:user)
    user.deactivate
    visit users_path
     within("#user_#{user.id}") do
      click_link "Edit"
    end
    expect {
      fill_in "User swipe card id/barcode", with: admin_user.swipe_card_id
      check "Active"
      click_button "Update User"
    }.to change{user.reload.active?}.from(false).to(true)
    expect(page).to have_content("User successfully updated")
  end

  it "Reports an error if the user adds a user with invalid attributes" do
    user = build(:user)
    visit users_path
    click_link "Add new user"
    expect {
      fill_in "User swipe card id/barcode", with: admin_user.swipe_card_id
      fill_in "Swipe card", with: user.swipe_card_id
      fill_in "Barcode", with: user.barcode
      select teams.first.name, from: "Team"
      click_button "Create User"
    }.to_not change(User, :count)
    expect(page).to have_content("error prohibited this record from being saved")
  end

  describe "drilling down", js: true do
    it "should allow viewing of associated audits" do
      user = create(:user_with_audits)
      visit users_path
      within("#user_#{user.id}") do
        click_link "Audits"
      end
      user.audits.each do |audit|
        expect(page).to have_content(audit.record_data)
      end
    end
  end

end
