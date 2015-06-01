class SearchResult

  include Enumerable
  include ActiveModel::Serialization

  attr_reader :results, :count
  delegate [], :empty?, to: :results

  def initialize(results = {})
    @results = results
    @count = 0
  end

  def each(&block)
    results.each(&block)
  end

  def add(k,v)
    @results[k] = v unless v.empty?
    @count += v.length
  end
  
end