require 'rails_helper'

RSpec.describe "Printers", type: :feature do

  let!(:admin_user) { create(:admin) }

  it "Should allow a user to create a new printer" do 
    printer = build(:printer)
    visit printers_path
    click_link "Add new printer"
    expect {
      fill_in "Name", with: printer.name
      fill_in "Uuid", with: printer.uuid
      fill_in "User swipe card id/barcode", with: admin_user.barcode
      click_button "Create Printer"
    }.to change(Printer, :count).by(1)
    expect(page).to have_content("Printer successfully created")
  end

  it "Should allow a user to edit an existing printer" do 
    printer = create(:printer)
    new_printer = build(:printer)
    visit printers_path
    expect {
      find(:data_id, printer.id).click_link "Edit"
      fill_in "User swipe card id/barcode", with: admin_user.barcode
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
      fill_in "User swipe card id/barcode", with: admin_user.barcode
      fill_in "Name", with: printer.name
      click_button "Create Printer"
    }.to_not change(Printer, :count)
    expect(page).to have_content("error prohibited this record from being saved")
  end

  it "Prevents a user from adding a printer if they are not authorised" do
    standard_user = create(:standard)
    printer = build(:printer)
    visit printers_path
    click_link "Add new printer"
    expect {
      fill_in "User swipe card id/barcode", with: standard_user.barcode
      fill_in "Name", with: printer.name
      fill_in "Uuid", with: printer.uuid
      click_button "Create Printer"
    }.to_not change(Printer, :count)
    expect(page).to have_content("error prohibited this record from being saved")
  end

   it "Prevents a user from editing an existing printer if they are not authorised" do
      printer = create(:printer)
      new_printer = build(:printer)
      standard_user = create(:standard)
      visit printers_path
      expect {
        within("#printer_#{printer.id}") do
          click_link "Edit"
        end
        fill_in "User swipe card id/barcode", with: standard_user.barcode
        fill_in "Name", with: new_printer.name
        click_button "Update Printer"
      }.to_not change(Printer, :count)
      expect(page).to have_content("error prohibited this record from being saved")
    end

  describe "audits", js: true do

    it "allows a user to view associated audits for a printer" do
      printer = create(:printer_with_audits)
      visit printers_path
      find(:data_id, printer.id).find(:data_behavior, "drilldown").click
      printer.audits.each do |audit|
        expect(page).to have_content(audit.record_data)
      end
    end

  end

end