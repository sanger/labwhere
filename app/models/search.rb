# frozen_string_literal: true

##
# Each search that is submitted will be stored along with its count.
# Could be useful for checking what kind of searches are carried out and how often.
class Search < ApplicationRecord
  validates :term, presence: true, uniqueness: { case_sensitive: false }

  after_find :bump_count

  include Searchable::Orchestrator

  searches_in :location_type, :location, :labware

  private

  def bump_count
    increment! :search_count
  end
end
