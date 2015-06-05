##
# Used by Search
# An object which will be returned by the search or the api.
class SearchResult

  include Enumerable
  include ActiveModel::Serialization

  ##
  # An array of all of the objects that are returned by the search.
  attr_reader :results

  ##
  # The number of results returned by the search
  attr_reader :count

  delegate [], :empty?, to: :results

  ##
  # If the results are passed will add them to SearchResult otherwise create an empty result.
  # Reset the count
  def initialize(results = {})
    @results = results
    @count = 0
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
  # Increase the result count.
  def add(k,v)
    @results[k] = v unless v.empty?
    @count += v.length
  end
  
end