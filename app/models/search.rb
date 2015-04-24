class Search < ActiveRecord::Base

  validates :term, presence: true, uniqueness: {case_sensitive: false}

  after_find :bump_count

  include Searchable::Orchestrator

  searches_in :location_type, :location, :labware

private

  def bump_count
    Search.increment_counter :search_count, self.id
  end

end
