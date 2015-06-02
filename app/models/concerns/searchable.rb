#TODO: improve the way the search method is done. At the moment it works by adding all the results together and then filtering.

##
# The Searchable module allows you to do a multi-model search across various attributes.
#
# It consists of a Client and an Orchestrator.
# You can have as many clients as you want must inherit from ActiveRecord. The Orchestrator will carry out the search.
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

  module Client

    extend ActiveSupport::Concern

    included do 
    end

    module ClassMethods

      def searchable_by(*attributes)
        define_singleton_method :search do |term|
          attributes.inject([]) do |result, attribute|
            result += where(arel_table[attribute].matches("%#{term}%"))
          end.uniq
        end
      end
    end

  end

  module Orchestrator

    extend ActiveSupport::Concern

    included do 
    end

    module ClassMethods

      def searches_in(*models)
        define_singleton_method :searchable_models do
          Hash[models.collect { |model| [model, model.to_s.classify.constantize] }]
        end
      end

    end

    def results
      @results ||= SearchResult.new.tap do |result|
        self.class.searchable_models.each do |k, v|
          result.add k.pluralize, v.search(self.term)
        end
      end
    end

  end
  
end