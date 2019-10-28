FactoryBot.define do
  factory :team do
    sequence(:number) { |n| n }
    name { "Team #{number}" }

    factory :team_with_audits do
      transient do
        user { create(:user) }
      end

      after(:create) do |team, evaluator|
        1.upto(5) do |_n|
          FactoryBot.create(:audit, auditable_type: team.class,
                                    auditable_id: team.id, user: evaluator.user, record_data: team)
        end
      end
    end
  end
end
