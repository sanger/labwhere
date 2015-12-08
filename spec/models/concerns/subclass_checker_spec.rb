require "rails_helper"

RSpec.describe SubclassChecker, type: :model do

  class Potato

    include SubclassChecker
    has_subclasses :baked, :roast, suffix: true
    def type
      self.class.to_s
    end
  end

  class BakedPotato < Potato
  end

  class RoastPotato < Potato
  end

  class Person
    include SubclassChecker
    has_subclasses :child, :parent
    def type
      self.class.to_s
    end
  end

  class Child < Person
  end

  class Parent < Person
  end

  class XmasSongs
    include SubclassChecker
    has_subclasses :jingle_bells, :xmas_tree
    def type
      self.class.to_s
    end
  end

  class JingleBells < XmasSongs
  end

  class XmasTree < XmasSongs
  end

  context "Potato - with a suffix" do

    it "Potato should not be Baked or Roasted" do
      expect(Potato.new).to_not be_baked
      expect(Potato.new).to_not be_roast
    end

    it "Baked Potato should Baked but not Roast" do
      expect(BakedPotato.new).to_not be_roast
      expect(BakedPotato.new).to be_baked
    end

    it "Roast Potato should be Roast but not Baked" do
      expect(RoastPotato.new).to_not be_baked
      expect(RoastPotato.new).to be_roast
    end
  end

  context "Person - without a suffix" do

    it "Person should not be Child or Parent" do
      expect(Person.new).to_not be_child
      expect(Person.new).to_not be_parent
    end

    it "Child should be Child but not Parent" do
      expect(Child.new).to_not be_parent
      expect(Child.new).to be_child
    end

    it "Parent should be Parent but not Child" do
      expect(Parent.new).to_not be_child
      expect(Parent.new).to be_parent
    end
  end

  context "Xmas Songs - underscored" do

    it "XmasSongs should not be JingleBells or XmasTree" do
      expect(XmasSongs.new).to_not be_jingle
      expect(XmasSongs.new).to_not be_xmas
    end

    it "JingleBells should be JingleBells not XmasTree" do
      expect(JingleBells.new).to be_jingle
      expect(JingleBells.new).to_not be_xmas
    end

    it "XmasTree should be XmasTree not JingleBells" do
      expect(XmasTree.new).to_not be_jingle
      expect(XmasTree.new).to be_xmas
    end
  
  end




end