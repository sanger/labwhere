# frozen_string_literal: true

require "rails_helper"

class ALovelyModel
  def marry
    "a#{attr_a}"
  end

  def pad
    attr_a.to_s * 5
  end
end

RSpec.describe FormObject::FormVariables, type: :model do
  let(:form_variables)  { FormObject::FormVariables.new(ALovelyModel, nil, [:controller, :action]) }

  let(:params)          { { controller: "controller", action: "action", a_lovely_model: { attr_a: "a", attr_b: "b", attr_d: "d" } } }
  let(:unnested_params) { { attr_a: "a", attr_b: "b" } }
  let(:model)           { ALovelyModel.new }

  before(:each) do
    form_variables.add(:attr_a, :attr_b, { attr_c: :marry }, :attr_d, { attr_e: :pad })
  end

  it "should have all of the variable names" do
    expect(form_variables.variables.length).to eq(8)
  end

  it "should add the reader variable names" do
    expect(form_variables.readers.length).to eq(2)
  end

  it "should add the accessor variable names" do
    expect(form_variables.writers.length).to eq(3)
  end

  it "should add the derived variable names" do
    expect(form_variables.derived.length).to eq(2)
  end

  it "should add the model key" do
    expect(form_variables.model_key).to eq(:a_lovely_model)
  end

  it "should assign the instance name" do
    expect(form_variables.find(:attr_a).instance).to eq("@attr_a")
  end

  it "should return the variable if no method is attached" do
    expect(form_variables.find(:attr_a).assign(model, params[:a_lovely_model][:attr_a])).to eq("a")
  end

  it "should return the modified variable if a method is attached" do
    form_variables.find(:attr_a).assign(model, params[:a_lovely_model][:attr_a])
    expect(form_variables.find(:attr_c).assign(model, nil)).to eq("aa")
  end

  it "assign should assign all of the attributes" do
    form_variables.assign(model, params)
    expect(model.controller).to eq("controller")
    expect(model.action).to eq("action")
    expect(model.attr_a).to eq("a")
    expect(model.attr_b).to eq("b")
    expect(model.attr_c).to eq("aa")
    expect(model.attr_d).to eq("d")
    expect(model.attr_e).to eq("aaaaa")
    expect(model.params).to eq(params)
  end

  it "assign should assign all of the attributes if they are not nested" do
    form_variables.assign(model, unnested_params)
    expect(model.attr_a).to eq("a")
    expect(model.attr_b).to eq("b")
    expect(model.attr_c).to eq("aa")
  end

  it "should assign the correct model key if provided" do
    form_variables = FormObject::FormVariables.new(ALovelyModel, :another_model_key)
    expect(form_variables.model_key).to eq(:another_model_key)
  end
end
