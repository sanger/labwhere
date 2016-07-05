class MyFakeValidator < ActiveModel::Validator
  def validate(record)
  end
end

FactoryGirl.define do

  factory :restriction do
    location_type
    validator { MyFakeValidator }

    factory :parentage_restriction, class: "ParentageRestriction" do

      after(:create) do |parentage_restriction, evaluator|
        1.upto(2) { parentage_restriction.location_types << FactoryGirl.create(:location_type) }
      end

    end
  end

end
