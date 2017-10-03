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

  context 'with one location and multiple copies' do

    subject { Label.new(location, 2) }

    it_behaves_like 'a label'

    it 'creates two copies of the same label for the body' do
      expect(subject.body.length).to eql(2)
      subject.body.each do |body_elem|
        expect(body_elem[:location][:barcode]).to eql(location.barcode)
        expect(body_elem[:location][:parent_location]).to eql(location.parent.name)
        expect(body_elem[:location][:location]).to eql(location.name)
      end
    end
  end

  context 'with many locations and multiple copies' do

    subject { Label.new(locations, 2) }

    it_behaves_like 'a label'

    it 'creates three copies of the labels for the body' do
      expect(subject.body.length).to eql(6)
      subject.body.each.with_index do |body_elem, n|
        expect(body_elem[:location][:barcode]).to eql(locations[n % 3].barcode)
        expect(body_elem[:location][:parent_location]).to eql(locations[n % 3].parent.name)
        expect(body_elem[:location][:location]).to eql(locations[n % 3].name)
      end
    end
  end

end
