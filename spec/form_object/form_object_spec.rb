# frozen_string_literal: true

require "rails_helper"

RSpec.describe FormObject, type: :model do |_variable|
  # rubocop:disable Lint/ConstantDefinitionInBlock
  with_model :ModelA do
    table do |t|
      t.string :name
      t.timestamps null: false
    end

    model do
      validates_presence_of :name
    end
  end

  with_model :ModelB do
    table do |t|
      t.string :name
      t.timestamps null: false
    end

    model do
    end
  end

  with_model :ModelDuck do
    table do |t|
      t.string :name
      t.timestamps null: false
    end

    model do
    end
  end

  with_model :ShesA do
    table do |t|
      t.string :name
      t.timestamps null: false
    end

    model do
    end
  end
  before(:all) do
    class ModelAForm
      include FormObject

      set_attributes :name
      set_form_variables :attr_a, attr_b: :modify_a
      after_submit :set_last
      attr_reader :last

      def modify_a
        "modified #{attr_a}"
      end

      def set_last
        @last = "boom"
      end
    end

    class ModelBForm
      include FormObject

      attr_reader :shout

      set_attributes :name

      after_validate do
        model.save
        @shout = "hallelujah!"
      end
    end

    class ModelDuckForm
      include FormObject

      set_attributes :name

      attr_reader :duck

      validate :duck_quacks

      after_assigning_model_variables :set_duck

      def set_duck
        @duck = "quack"
      end

      def duck_quacks
        errors.add(:base, "Your duck is not quacking") unless duck
      end
    end

    class ShesAModelAndShesLookingGoodForm
      include FormObject

      set_form_variables :attr_a
    end
    # rubocop:enable Lint/ConstantDefinitionInBlock
  end

  it "should assign the top level attributes attributes" do
    params = ActionController::Parameters.new(controller: "controller", action: "action", model_a: {})
    model_a_form = ModelAForm.new
    model_a_form.submit(params)
    expect(model_a_form.params).to eq(params)
    expect(model_a_form.controller).to eq("controller")
    expect(model_a_form.action).to eq("action")
  end

  it "should assign the form instance variables" do
    params = ActionController::Parameters.new(model_a: { attr_a: "attr_a" })
    model_a_form = ModelAForm.new
    model_a_form.submit(params)
    expect(model_a_form.attr_a).to eq('attr_a')
  end

  it "should assign form instance variables by method" do
    params = ActionController::Parameters.new(model_a: { attr_a: "attr_a" })
    model_a_form = ModelAForm.new
    model_a_form.submit(params)
    expect(model_a_form.attr_b).to eq('modified attr_a')
  end

  it "should run the callbacks" do
    model_a_form = ModelAForm.new
    model_a_form.submit(ActionController::Parameters.new(model_a: { name: "A name" }))
    expect(model_a_form.last).to eq("boom")

    model_a_form = ModelAForm.new
    model_a_form.submit(ActionController::Parameters.new(model_a: {}))
    expect(model_a_form.last).to be_nil

    model_duck_form = ModelDuckForm.new
    model_duck_form.submit(ActionController::Parameters.new(model_duck: {}))
    expect(model_duck_form).to be_valid
  end

  it "allows creation of a new record with valid attributes" do
    expect {
      ModelAForm.new.submit(ActionController::Parameters.new(model_a: { name: "A name" }))
    }.to change(ModelA, :count).by(1)

    expect {
      ModelBForm.new.submit(ActionController::Parameters.new(model_b: { name: "A name" }))
    }.to change(ModelB, :count).by(1)
  end

  it "prevents creation of record with invalid attributes" do
    model_a_form = ModelAForm.new
    expect {
      model_a_form.submit(ActionController::Parameters.new(model_a: { name: nil }))
    }.to_not change(ModelA, :count)
    expect(model_a_form).to_not be_valid
    expect(model_a_form.errors.count).to eq(1)
  end

  it "allows updating of existing record with valid attributes" do
    model_a = ModelA.create(name: "A name")
    model_a_form = ModelAForm.new(model_a)
    expect(model_a_form.id).to eq(model_a.id)
    expect(model_a_form).to be_persisted
    expect {
      model_a_form.submit(ActionController::Parameters.new(model_a: { name: "Another name" }))
    }.to change { model_a.reload.name }.to("Another name")
  end

  it "should be able to modify the save options" do
    model_b_form = ModelBForm.new
    model_b_form.submit(ActionController::Parameters.new(model_b: { name: "A name" }))
    expect(model_b_form.shout).to eq("hallelujah!")
    expect(ModelB.count).to eq(1)
  end

end
