class MyFakeValidator < ActiveModel::Validator
  def validate(record)
  end
end

FactoryBot.define do

  factory :restriction do
    location_type
    validator { MyFakeValidator }

    factory :parentage_restriction, class: "ParentageRestriction" do

      after(:create) do |parentage_restriction, evaluator|
        create_list(:location_types_restriction, 2, parentage_restriction: parentage_restriction)
      end

    end
  end

end
