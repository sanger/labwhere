# frozen_string_literal: true

# Rails task to fix children_count for all locations
# children_count is a counter cache column that stores the number of children a location has managed by ancestry gem
# The task is useful when the children_count column is out of sync with the actual number of children
# The task iterates through all locations and updates the children_count column to the correct value
namespace :location do
  desc 'Fix children_count for all locations'
  task fix_children_count: :environment do
    Location.find_each do |location|
      correct_count = location.children.count
      if location.children_count != correct_count
        location.update_column(:children_count, correct_count) # rubocop:disable Rails/SkipsModelValidations
        puts "Updated children_count for Location #{location.id} to #{correct_count}"
      end
    end
  end
end
