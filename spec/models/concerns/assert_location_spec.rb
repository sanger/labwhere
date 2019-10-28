require "rails_helper"

RSpec.describe AssertLocation, type: :model do
  with_model :my_model do
    table do |t|
      t.string :name
      t.integer :location_id
    end

    model do
      belongs_to :location

      include AssertLocation
    end
  end

  it "should always add the unknown location if it is empty" do
    my_model = MyModel.create(name: "My Model")
    expect(my_model.location).to eq(UnknownLocation.get)
  end

  it "should not add the unknown location if it is not empty" do
    my_model = MyModel.create(name: "My Model", location: create(:location))
    expect(my_model.location).to_not eq(UnknownLocation.get)
  end
end
