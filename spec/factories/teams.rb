FactoryGirl.define do
  factory :team do
    sequence(:number) {|n| n }
    name {"Team #{number}"}
  end

end
