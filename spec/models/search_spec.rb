require 'rails_helper'

RSpec.describe Search, type: :model do
  it "should not be valid without a term" do
    expect(build(:search, term: nil)).to_not be_valid
  end

  it "term should be unique" do
    search = create(:search)
    expect(build(:search, term: search.term)).to_not be_valid
  end

  # it "should increment count each time the search term is used" do
  #   search = create(:search)
  #   expect(search.search_count).to eq(0)
  #   expect(Search.find(search.id).search_count).to eq(1)
  #   expect(Search.find(search.id).search_count).to eq(2)
  #   expect(Search.find(search.id).search_count).to eq(3)
  #   # Rails 5 version of increment! does not cause timestamp to change
  #   # expect(Search.find(search.id).updated_at).to_not eq(search.updated_at)
  # end

  context "Results" do
    let!(:location_type_building) { create(:location_type, name: 'Building') }
    let!(:location_type_room) { create(:location_type, name: "Room") }
    let!(:location_type_freezer) { create(:location_type, name: "Freezer") }
    let!(:location_building) { create(:location, name: 'Building', location_type: location_type_building) }
    let!(:location_freezer_1) { create(:location, name: "Freezer 1", location_type: location_type_room, parent: location_building) }
    let!(:location_freezer_2) { create(:location, name: "Freezer 2", location_type: location_type_room, parent: location_building) }
    let!(:location_shelf_123) { create(:location, name: "Shelf 123", location_type: location_type_freezer, parent: location_freezer_1) }
    let!(:labware_1) { create(:labware) }
    let!(:labware_2) { create(:labware) }

    it "should be empty if nothing matches the term" do
      expect(Search.create(term: "dodgy term").results).to be_empty
    end

    it "should return location type if it matches the term" do
      search = Search.create(term: "room")
      expect(search.results.count).to eq(1)
      expect(search.results[:location_types]).to include(location_type_room)
    end

    it "should return the location if it matches the term" do
      search = Search.create(term: "Freezer 1")
      expect(search.results.count).to eq(1)
      expect(search.results[:locations]).to include(location_freezer_1)
    end

    it "should return the labware if it matches the term" do
      search = Search.create(term: labware_1.barcode)
      expect(search.results.count).to eq(1)
      expect(search.results[:labwares]).to include(labware_1)
    end

    it "should return multiple resources if they match the term" do
      search = Search.create(term: "freezer")
      expect(search.results.count).to eq(3)
      expect(search.results[:location_types]).to include(location_type_freezer)
      expect(search.results[:locations]).to include(location_freezer_1)
      expect(search.results[:locations]).to include(location_freezer_2)
      expect(search.message).to eq("Your search returned 3 results.")
    end

    it "should return a result if the barcode matches the term" do
      search = Search.create(term: location_shelf_123.barcode)
      expect(search.results.count).to eq(1)
      expect(search.results[:locations]).to include(location_shelf_123)
      expect(search.message).to eq("Your search returned 1 result.")
    end
  end
end
