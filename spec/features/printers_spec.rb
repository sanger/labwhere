require 'rails_helper'

RSpec.describe "Printers", type: :feature do

  it "Should allow a user to create a new printer" do 
    printer = build(:printer)
    visit printers_path
    click_link "Add new printer"
    expect {
      fill_in "Name", with: printer.name
      fill_in "Uuid", with: printer.uuid
      click_button "Create Printer"
    }.to change(Printer, :count).by(1)
    expect(page).to have_content("Printer successfully created")
  end

  it "Should allow a user to edit an existing printer" do 
    printer = create(:printer)
    new_printer = build(:printer)
    visit printers_path
    expect {
      within("#printer_#{printer.id}") do
        click_link "Edit"
      end
      fill_in "Name", with: new_printer.name
      click_button "Update Printer"
    }.to change { printer.reload.name }.to(new_printer.name)
    expect(page).to have_content("Printer successfully updated")
  end

  it "Should return an error if a printer is created with invalid attributes" do 
    printer = build(:printer)
    visit printers_path
    click_link "Add new printer"
    expect {
      fill_in "Name", with: printer.name
      click_button "Create Printer"
    }.to_not change(Printer, :count)
    expect(page).to have_content("error prohibited this record from being saved")
  end

end