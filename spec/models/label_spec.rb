# frozen_string_literal: true

require 'rails_helper'

RSpec.shared_examples 'a label' do
  describe '#body' do
    it 'creates the body from the location(s)' do
      expect(subject.body).to be_kind_of Array
    end
  end
end

RSpec.describe Label, type: :model do
  let!(:location) { create(:location) }
  let!(:locations) { create_list(:location, 3) }

  context 'with one location' do
    subject { Label.new(location) }

    it_behaves_like 'a label'

    it 'creates one label for the body' do
      expect(subject.body.length).to eql(1)

      expect(subject.body[0][:barcode]).to eql(location.barcode)
      expect(subject.body[0][:parent_location]).to eql(location.parent.name)
      expect(subject.body[0][:location]).to eql(location.name)
      expect(subject.body[0][:label_name]).to eql("location")
    end
  end

  context 'with many locations' do
    subject { Label.new(locations) }

    it_behaves_like 'a label'

    it 'creates many labels for the body' do
      expect(subject.body.length).to eql(3)

      locations.each.with_index do |location, n|
        expect(subject.body[n][:barcode]).to eql(location.barcode)
        expect(subject.body[n][:parent_location]).to eql(location.parent.name)
        expect(subject.body[n][:location]).to eql(location.name)
        expect(subject.body[n][:label_name]).to eql('location')
      end
    end
  end
end
