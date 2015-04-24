require "rails_helper"

RSpec.describe Searchable, type: :model do 

  with_model :Label do
    table do |t|
      t.string :name
      t.timestamps null: false
    end

    model do
      include Searchable::Client

      searchable_by :name
    end
    
  end

  with_model :BarcodeLabel do
    table do |t|
      t.string :name
      t.string :barcode
      t.timestamps null: false
    end

    model do
      include Searchable::Client

      searchable_by :name, :barcode
    end
  end

  with_model :Search do
    table do |t|
      t.string :term
      t.timestamps null: false
    end

    model do
      include Searchable::Orchestrator

      searches_in :label, :barcode_label
    end
  end

  describe Searchable::Client do
    it "should allow for search by term" do
      Label.create(name: "A name")
      Label.create(name: "Another name")
      Label.create(name: "Gobbledeyguke")

      expect(Label.search("name").count).to eq(2)
      expect(Label.search("Gobbledeyguke").count).to eq(1)
      expect(Label.search("gobbledeyguke").count).to eq(1)
      expect(Label.search("gobble").count).to eq(1)

    end

    it "should allow for search by term on multiple fields" do
      BarcodeLabel.create(name: "A name")
      BarcodeLabel.create(name: "Another name")
      BarcodeLabel.create(barcode: "Gobbledeyguke")

      expect(BarcodeLabel.search("name").count).to eq(2)
      expect(BarcodeLabel.search("Gobbledeyguke").count).to eq(1)
      expect(BarcodeLabel.search("gobbledeyguke").count).to eq(1)
      expect(BarcodeLabel.search("gobble").count).to eq(1)
    end

    it "should remove duplicate records" do
      BarcodeLabel.create(name: "A name", barcode: "A name:1")

      expect(BarcodeLabel.search("A name").count).to eq(1)
    end
  end

  describe Searchable::Orchestrator do

    it "should return an empty result if nothing matches" do
      Label.create(name: "A name")
      BarcodeLabel.create(name: "Another name")

      expect(Search.create(term: "A dodgy term").results).to be_empty
    end

    it "should return results if the term matches" do
      Label.create(name: "A name")
      BarcodeLabel.create(name: "A name")
      BarcodeLabel.create(barcode: "Gobbledeyguke")

      expect(Search.create(term: "name").results.count).to eq(2)
      expect(Search.create(term: "Gobbledey").results.count).to eq(1)

    end
  end

end