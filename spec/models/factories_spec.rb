require 'rails_helper'

RSpec.describe "Factories" do

  FactoryGirl.factories.map(&:name).each do |factory_name|
    it "The #{factory_name} factory is valid" do
      expect(build(factory_name)).to be_valid
    end
  end
  
end