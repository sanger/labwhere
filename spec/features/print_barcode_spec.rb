require 'rails_helper'

RSpec.describe LabelPrinter, type: :feature do

  let!(:location) { create(:location)}
  let!(:printer)  { create(:printer)}

  before(:each) do
    allow_any_instance_of(LabelPrinter).to receive(:post).and_return(true)
  end

  describe "printing", js: true do

    it "should allow a user to reprint a barcode for a location" do
      visit locations_path(location)
      find(:data_id, location.id).click_link "Print Barcode"
      select printer.name, from: "Printer"
      click_button "Print"
      expect(page).to have_content(I18n.t("printing.success"))
    end
  end
end