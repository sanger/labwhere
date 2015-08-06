##
# Used by Search
# An object which will be returned by the search or the api.
class SearchResult

  include Enumerable
  include ActiveModel::Serialization
  include ActionView::Helpers::TextHelper

  ##
  # An array of all of the objects that are returned by the search.
  attr_reader :results
  attr_reader :adjusted_count

  ##
  # The number of results returned by the search
  attr_accessor :count
  attr_accessor :limit

  delegate [], :empty?, to: :results

  ##
  # If the results are passed will add them to SearchResult otherwise create an empty result.
  # Reset the count
  def initialize(count: 0, limit: 0)
    @adjusted_count = 0
    @results = {}
    @count = count
    @limit = limit
    yield self if block_given?
  end

  ##
  # 
  #  search_result = SearchResult.new(results)
  #  search_result.each do |search|
  #   ...
  #  end => each result
  def each(&block)
    results.each(&block)
  end

  ##
  # Add an object to the results hash with key k unless it is empty.
  # result with key will be replaced.
  # if adding result exceeds the limit then only spare capacity will be added.
  def add(k,v)
    return if adjusted_count >= limit
    unless v.empty?
      if adjusted_count + v.length > limit
        @results[k] = v.take(limit - adjusted_count)
        @adjusted_count = limit
      else
        @results[k] = v
        @adjusted_count += v.length
      end
    end
  end

  def message
    return "Your search returned #{pluralize(count, "result")}." if count <= limit
    "Your search returned #{pluralize(count, "result")}. It has been limited to #{pluralize(limit, "result")}. Please refine your search."
  end
  
end