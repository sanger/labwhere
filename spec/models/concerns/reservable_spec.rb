require "rails_helper"

RSpec.describe Reservable, type: :model do

  with_model :MyModel do

    table do |t|
      t.integer :team_id
    end

    model do
      belongs_to :team
      include Reservable
    end

  end

  let(:model)            { MyModel.create }
  let(:reserved_model)  { MyModel.create(team: create(:team)) }

  describe '#reserved?' do
    it 'is true when it has an associated team' do
      expect(reserved_model.reserved?).to eq(true)
    end

    it 'is false when it does not have an associated team' do
      expect(model.reserved?).to eq(false)
    end
  end

  describe '#reserve' do
    it 'sets the team on the model' do
      team = create(:team)
      expect(model.reserve(team)).to be_truthy
      expect(model.reserved?).to eq(true)
    end

    it 'returns false if there is already a team' do
      expect(reserved_model.reserve(create(:team))).to eql(false)
    end
  end

  describe '#release' do
    it 'sets the team to nil' do
      expect(reserved_model.release).to be_truthy
      expect(reserved_model.reserved?).to eq(false)
    end
  end

  describe '#reserved_by' do
    it 'returns the team that has reserved the model' do
      expect(reserved_model.reserved_by).to be(reserved_model.team)
    end

    it 'returns nil if the model is not reserved' do
      expect(model.reserved_by).to be_nil
    end
  end

end