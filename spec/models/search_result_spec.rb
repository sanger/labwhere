require 'rails_helper'

RSpec.describe SearchResult, type: :model do
  it "should assign the default attributes" do
    search_result = SearchResult.new
    expect(search_result.results).to be_empty
    expect(search_result.count).to be(0)
    expect(search_result.limit).to be(0)
  end

  it "should assign any passed attributes" do
    results = { a: [1, 2], b: [3, 4], c: [5, 6], d: [7, 8] }
    search_result = SearchResult.new(count: 10, limit: 5)
    expect(search_result.count).to eq(10)
    expect(search_result.limit).to eq(5)
  end

  it "should allow attributes to be assigned via a block" do
    search_result = SearchResult.new do |s|
      s.count = 5
      s.limit = 50
      { a: [1, 2], b: [3, 4], c: [] }.each do |k, v|
        s.add k, v
      end
    end
    expect(search_result.count).to eq(5)
    expect(search_result.limit).to eq(50)
    expect(search_result.results[:a]).to eq([1, 2])
    expect(search_result.results[:b]).to eq([3, 4])
    expect(search_result.results[:c]).to be_nil
  end

  it "should return the correct message" do
    search_result = SearchResult.new do |s|
      s.count = 5
      s.limit = 10
    end

    expect(search_result.message).to eq("Your search returned 5 results.")
    results = { a: [1, 2], b: [3, 4], c: [5, 6], d: [7, 8] }
    search_result = SearchResult.new do |s|
      s.limit = 6
      results.each do |k, v|
        s.add k, v
      end
      s.count = 8
    end

    expect(search_result.adjusted_count).to eq(6)
    expect(search_result.message).to eq("Your search returned 8 results. It has been limited to 6 results. Please refine your search.")
  end
end
