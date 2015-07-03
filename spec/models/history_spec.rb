require 'rails_helper'

RSpec.describe History, type: :model do

  let!(:labware) { create(:labware_with_histories) }

  it "#summary should be correct" do
    history = labware.histories.first
    expect(history.summary).to eq("Scanned in to #{history.scan.location.name} by #{history.scan.user.login} on #{history.created_at.to_s(:uk)}")
  end
  
end