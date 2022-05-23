# frozen_string_literal: true

# TODO: improve the way the search method is done. At the moment
# it works by adding all the results together and then filtering.

##
# The Searchable module allows you to do a multi-model search across various attributes.
#
# It consists of a Client and an Orchestrator.
# Example implementation:
#
#  class Model1
#   include Searchable::Client
#   searchable_by :attr_1, :attr_2
#  end
#
#  class Model2
#   include Searchable::Client
#   searchable_by :attr_3, :attr_4
#  end
#
#  class Search
#   include Searchable::Orchestrator
#   attr_accessor :term
#   searches_in :model1, :model2
#  end
#
# The Orchestrator must have a term attribute.
# To run a search:
#
#  search = Search.new(term: "A search term")
#  search.results = <#SearchResult: count: 2, results: [#SearchResult1, #SearchResult2]
#
# Each search result will be an ActiveRecord::Relation object.
#
module Searchable
  # You can have as many clients as you want but must inherit from ActiveRecord.
  module Client
    extend ActiveSupport::Concern

    module ClassMethods
      ##
      # Create a search method signified by the attributes.
      # For each attribute search the table for the term.
      # and strip out any duplicate records.
      # TODO: is there a  more efficient way to do this?
      def searchable_by(*attributes)
        define_singleton_method :search do |term|
          attributes.inject([]) do |result, attribute|
            result + where(arel_table[attribute].matches("%#{term}%"))
          end.uniq
        end
      end
    end
  end

  # The Orchestrator will carry out the search.
  module Orchestrator
    extend ActiveSupport::Concern

    included do
      delegate :message, to: :results
    end

    module ClassMethods
      ##
      # Define which models the Orchestrator will search through.
      # Also allows for a limit option to limit the search to a number of results.
      # The default for this is 1000.
      def searches_in(*models)
        options = models.extract_options!

        define_singleton_method :limit do
          options[:limit] ||= 1000
        end

        define_singleton_method :searchable_models do
          models.index_with { |model| model.to_s.classify.constantize }
        end
      end
    end

    ##
    # Create a results object.
    # For each model which has a result add a key, value pair.
    # Set the limit as defined by searches_in.
    # Will also add the true count of the results by adding the results of each search.
    def results
      count = 0

      @results ||= SearchResult.new do |result|
        result.limit = self.class.limit
        self.class.searchable_models.each do |k, v|
          search_result = v.search(term)
          result.add k.pluralize, search_result
          count += search_result.count
        end

        result.count = count
      end
    end
  end
end
