
require "rails_helper"

RSpec.describe "Users", type: :feature do

  it "Allows a user to create a new user" do
    user = build(:user)
    visit users_path
    click_link "Add new user"
    expect {
      fill_in "Login", with: user.login
      fill_in "Swipe card", with: user.swipe_card
      fill_in "Barcode", with: user.barcode
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
      fill_in "Swipe card", with: user_2.swipe_card
      click_button "Update User"
    }.to change { user.reload.swipe_card}.to(user_2.swipe_card)
  end

   it "Allows a user to archive an existing user" do
    user = create(:user)
    visit users_path
    expect {
      within("#user_#{user.id}") do
        click_link "Archive"
      end
    }.to change{ user.reload.deleted? }.to(true)
    expect(page).to have_content("User successfully archived")
  end

  it "Allows a user to create a different type of user" do
    user = build(:user)
    visit users_path
    click_link "Add new user"
    expect {
      fill_in "Login", with: user.login
      fill_in "Swipe card", with: user.swipe_card
      fill_in "Barcode", with: user.barcode
      select "Admin", from: "Type"
      click_button "Create User"
    }.to change(Admin, :count).by(1)
    expect(page).to have_content("User successfully created")
  end

end
