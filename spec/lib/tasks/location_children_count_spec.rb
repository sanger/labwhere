# frozen_string_literal: true

require 'rails_helper'
require 'rake'

RSpec.describe 'location:fix_children_count' do
  before do
    Rails.application.load_tasks
    Rake::Task['location:fix_children_count'].reenable
    @parent = create(:location)
    @child1 = create(:location, parent: @parent)
    @child2 = create(:location, parent: @parent)
    @grandchild = create(:location, parent: @child1)
  end

  context 'when children_count is out of sync and set to 0' do
    before do
      # Manually set children_count to 0 for all locations
      # rubocop:disable Rails/SkipsModelValidations
      @parent.update_column(:children_count, 0)
      @child1.update_column(:children_count, 0)
      @child2.update_column(:children_count, 0)
      # rubocop:enable Rails/SkipsModelValidations
    end
    it 'fixes the children_count for all locations and outputs the correct message' do
      expect(@parent.children_count).to eq(0)
      expect(@child1.children_count).to eq(0)
      expect do
        Rake::Task['location:fix_children_count'].invoke
      end.to output(
        "Updated children_count for Location #{@parent.id} to 2\n" \
        "Updated children_count for Location #{@child1.id} to 1\n"
      ).to_stdout

      expect(@parent.reload.children_count).to eq(2)
      expect(@child1.reload.children_count).to eq(1)
    end
  end
  context 'when children_count is out of sync and set to a non zero value' do
    before do
      # Manually set children_count to 100 for all locations
      # rubocop:disable Rails/SkipsModelValidations
      @parent.update_column(:children_count, 100)
      @child1.update_column(:children_count, 100)
      @child2.update_column(:children_count, 100)
      # rubocop:enable Rails/SkipsModelValidations
    end
    it 'fixes the children_count for all locations and outputs the correct message' do
      expect(@parent.children_count).to eq(100)
      expect(@child1.children_count).to eq(100)
      expect(@child2.children_count).to eq(100)
      expect do
        Rake::Task['location:fix_children_count'].invoke
      end.to output(
        "Updated children_count for Location #{@parent.id} to 2\n" \
        "Updated children_count for Location #{@child1.id} to 1\n" \
        "Updated children_count for Location #{@child2.id} to 0\n"
      ).to_stdout
      expect(@parent.reload.children_count).to eq(2)
      expect(@child1.reload.children_count).to eq(1)
      expect(@child2.reload.children_count).to eq(0)
    end
  end
end
