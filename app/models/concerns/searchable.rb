#TODO: improve the way the search method is done. At the moment it works by adding all the results together and then filtering.

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
          models.collect { |model| model.to_s.classify.constantize }
        end
      end

    end

    def results
      @results ||= self.class.searchable_models.collect { |model| model.search(self.term) }.flatten
    end
  end
  
end