require 'rails_helper'

RSpec.describe Header, type: :model do

 it "params with index should produce a header which is not singularised" do
  params = {action: 'index', controller: 'localhost/controllers'}
  header = Header.new(params)
  expect(header.to_s).to eq("Controllers")
  expect(header.to_css_class).to eq("controllers")
 end

 it "params with new should prduce a header which is singularised preceded with the action" do
  params = {action: 'new', controller: 'localhost/controllers'}
  header = Header.new(params)
  expect(header.to_s).to eq("New Controller")
  expect(header.to_css_class).to eq("new-controller")
 end

 it "params with controller with underscores should separate with spaces" do
   params = {action: 'new', controller: 'localhost/my_controllers'}
   header = Header.new(params)
   expect(header.to_s).to eq("New My Controller")
   expect(header.to_css_class).to eq("new-my-controller")
 end
  
end