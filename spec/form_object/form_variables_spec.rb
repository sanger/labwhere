require "rails_helper"

RSpec.describe FormObject::FormVariables, type: :model do |variable|
  
  class ALovelyLittleModel

    attr_accessor :attr_a, :attr_b, :attr_c
    attr_reader :params, :attr_d, :attr_e

    def marry(b)
      "a" + b.to_s
    end
    
  end

  let(:form_variables)  { FormObject::FormVariables.new(:little_model, :params, :attr_d, :attr_e) }

  let(:params)          { { attr_d: "d", attr_e: "e", little_model: {attr_a: "a", attr_c: "c", attr_b: "b"} } }
  let(:unnested_params) { { attr_a: "a", attr_c: "c", attr_b: "b"} }
  let(:model)           { ALovelyLittleModel.new }

  before(:each) do
    form_variables.add(:attr_a, :attr_b, attr_c: :marry)
  end

  it "should add the top level variable names" do
    expect(form_variables.controller).to eq([:params, :attr_d, :attr_e])
  end

  it "should add the nested variable names" do
    expect(form_variables.model).to eq([:attr_a, :attr_b, :attr_c])
  end

  it "should add the model key" do
    expect(form_variables.model_key).to eq(:little_model)
  end

  it "should assign the instance name" do
    expect(form_variables.find(:attr_a).instance).to eq("@attr_a")
  end

  it "should return the variable if no method is attached" do
    expect(form_variables.find(:attr_a).assign(model, params[:little_model][:attr_a])).to eq("a")
  end

  it "should return the modified variable if a method is attached" do
    expect(form_variables.find(:attr_c).assign(model, params[:little_model][:attr_c])).to eq("ac")
  end

  it "assign should assign all of the attributes" do
    form_variables.assign_all(model, params)
    expect(model.attr_a).to eq("a")
    expect(model.attr_b).to eq("b")
    expect(model.attr_c).to eq("ac")
    expect(model.attr_d).to eq("d")
    expect(model.attr_e).to eq("e")
    expect(model.params).to eq(params)
  end

   it "assign should assign all of the attributes if they are not nested" do
    form_variables.assign_top_level(model, unnested_params)
    expect(model.attr_a).to eq("a")
    expect(model.attr_b).to eq("b")
    expect(model.attr_c).to eq("ac")
  end

end