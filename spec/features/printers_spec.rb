# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Printers', type: :feature do
  let!(:administrator) { create(:administrator) }
  let!(:technician) { create(:technician) }
  let!(:scientist) { create(:scientist) }

  it 'Should allow a user to create a new printer' do
    printer = build(:printer)
    visit printers_path
    click_link 'Add new printer'
    expect do
      fill_in 'Name', with: printer.name
      fill_in 'User swipe card id/barcode', with: administrator.barcode
      click_button 'Create Printer'
    end.to change(Printer, :count).by(1)
    expect(page).to have_content('Printer successfully created')
  end

  it 'Should allow a user to edit an existing printer' do
    printer = create(:printer)
    new_printer = build(:printer)
    visit printers_path
    expect do
      find(:data_id, printer.id).click_link 'Edit'
      fill_in 'User swipe card id/barcode', with: administrator.barcode
      fill_in 'Name', with: new_printer.name
      click_button 'Update Printer'
    end.to change { printer.reload.name }.to(new_printer.name)
    expect(page).to have_content('Printer successfully updated')
  end

  it 'Should return an error if a printer is created with invalid attributes' do
    build(:printer)
    visit printers_path
    click_link 'Add new printer'
    expect do
      fill_in 'User swipe card id/barcode', with: administrator.barcode
      click_button 'Create Printer'
    end.to_not change(Printer, :count)
    expect(page).to have_content('error prohibited this record from being saved')
  end

  it 'Prevents scientists from adding a printer as they are not authorised' do
    printer = build(:printer)
    visit printers_path
    click_link 'Add new printer'
    expect do
      fill_in 'User swipe card id/barcode', with: scientist.barcode
      fill_in 'Name', with: printer.name
      click_button 'Create Printer'
    end.to_not change(Printer, :count)
    expect(page).to have_content('error prohibited this record from being saved')
    expect(page).to have_content('User is not authorised')
  end

  it 'Prevents scientists from editing an existing printer as they are not authorised' do
    printer = create(:printer)
    new_printer = build(:printer)
    visit printers_path
    expect do
      within("#printer_#{printer.id}") do
        click_link 'Edit'
      end
      fill_in 'User swipe card id/barcode', with: scientist.barcode
      fill_in 'Name', with: new_printer.name
      click_button 'Update Printer'
    end.to_not change(Printer, :count)
    expect(page).to have_content('error prohibited this record from being saved')
    expect(page).to have_content('User is not authorised')
  end

  # This test causes intermittent failures on CI. Not sure why.
  # Tried various things and it seems less trouble to skip it
  # as we know these tests are mature and pass
  # Next step would be to fix or remove
  describe 'audits', js: true do
    it 'allows a user to view associated audits for a printer' do
      printer = create(:printer_with_audits)
      visit printers_path
      first(:data_id, printer.id).find(:data_behavior, 'drilldown').click
      expect(first(:data_id, printer.id)).to have_css('article', count: 5)
    end
  end
end
