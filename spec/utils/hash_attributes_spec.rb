# frozen_string_literal: true

require "rails_helper"

class TestHashAttributes
  attr_reader :attr_a, :attr_b, :attr_c

  include HashAttributes

  def initialize(attributes = {})
    set_attributes(attributes)
  end
end

class TestParamsAttributes
  include HashAttributes
  attr_reader :controller, :action, :attr_a, :attr_b, :attr_c

  def initialize(attributes = {})
    set_params_attributes(:nested, attributes)
  end
end

RSpec.describe HashAttributes, type: :model do
  it "with arguments passed should create instance variables" do
    obj = TestHashAttributes.new({ attr_a: "aaa", attr_b: "bbb", attr_c: "ccc" })
    expect(obj.attr_a).to eq("aaa")
    expect(obj.attr_b).to eq("bbb")
    expect(obj.attr_c).to eq("ccc")
  end

  it "with arguments passed should create instance variables" do
    obj = TestParamsAttributes.new({ controller: "a controller", action: "an action", something_else: "a load of rubbish", nested: { attr_a: "aaa", attr_b: "bbb", attr_c: "ccc" } })
    expect(obj.controller).to eq("a controller")
    expect(obj.action).to eq("an action")
    expect(obj.attr_a).to eq("aaa")
    expect(obj.attr_b).to eq("bbb")
    expect(obj.attr_c).to eq("ccc")
  end
end
