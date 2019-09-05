FactoryBot.define do
  factory :audit do
    transient do
      location { create(:location) }
    end
    auditable_type { location.class }
    action "create"
    record_data  { location }
    auditable_id { location.id }
    user
  end

end
