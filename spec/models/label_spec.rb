require 'rails_helper'

RSpec.shared_examples 'a label' do
  describe '#header' do
    it 'has a header label' do
      expect(subject.header).to have_key 'header_text_1'
      expect(subject.header).to have_key 'header_text_2'
      expect(subject.header['header_text_1']).to eql 'header by LabWhere'
      expect(subject.header['header_text_2']).to eql 'header'
    end
  end

  describe '#footer' do
    it 'has a footer label' do
      expect(subject.footer).to have_key 'footer_text_1'
      expect(subject.footer).to have_key 'footer_text_2'
      expect(subject.footer['footer_text_1']).to eql 'footer by LabWhere'
      expect(subject.footer['footer_text_2']).to eql 'footer'
    end
  end

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

      expect(subject.body[0][:location][:barcode]).to eql(location.barcode)
      expect(subject.body[0][:location][:parent_location]).to eql(location.parent.name)
      expect(subject.body[0][:location][:location]).to eql(location.name)
    end

  end

  context 'with many locations' do

    subject { Label.new(locations) }

    it_behaves_like 'a label'

    it 'creates many labels for the body' do
      expect(subject.body.length).to eql(3)

      locations.each.with_index do |location, n|
        expect(subject.body[n][:location][:barcode]).to eql(location.barcode)
        expect(subject.body[n][:location][:parent_location]).to eql(location.parent.name)
        expect(subject.body[n][:location][:location]).to eql(location.name)
      end
    end

  end

end