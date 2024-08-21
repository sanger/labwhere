# frozen_string_literal: true

require 'rails_helper'
require 'rake'

RSpec.describe 'location:fix_children_count' do
  before do
    Rails.application.load_tasks
    @parent = create(:location)
    @child1 = create(:location, parent: @parent)
    @child2 = create(:location, parent: @parent)
    @grandchild = create(:location, parent: @child1)

    # Manually set children_count to 0 for all locations
    # rubocop:disable Rails/SkipsModelValidations
    @parent.update_column(:children_count, 0)
    @child1.update_column(:children_count, 0)
    @child2.update_column(:children_count, 0)
    # rubocop:enable Rails/SkipsModelValidations
  end

  it 'fixes the children_count for all locations and outputs the correct message' do
    expect do
      Rake::Task['location:fix_children_count'].invoke
    end.to output(/Updated children_count for Location #{@parent.id} to 2\nUpdated children_count for Location 2 to 1/)
       .to_stdout

    expect(@parent.reload.children_count).to eq(2)
    expect(@child1.reload.children_count).to eq(1)
  end
end
