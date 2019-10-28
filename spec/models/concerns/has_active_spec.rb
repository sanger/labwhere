require "rails_helper"

RSpec.describe HasActive, type: :model do
  with_model :TestModel do
    table do |t|
      t.string :name
      t.integer :status, default: 0
      t.datetime :deactivated_at
      t.timestamps null: false
    end

    model do
      include HasActive
    end
  end

  let!(:model) { TestModel.create(name: "Test Model") }

  it "should be active when first created" do
    expect(model).to be_active
  end

  it "when deactivated should set it to inactive and record the date and time it was done" do
    model.deactivate
    expect(model).to be_inactive
    expect(model.deactivated_at).to_not be_nil
  end

  it "when activated should set it to inactive and remove deactivated_at" do
    model.deactivate
    model.activate
    expect(model).to be_active
    expect(model.deactivated_at).to be_nil
  end
end
