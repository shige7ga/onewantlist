FactoryBot.define do
  factory :user_status do
    association :user
    last_login_date { Date.current }
  end
end
