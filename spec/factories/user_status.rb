FactoryBot.define do
  factory :user_status do
    association :owner, factory: :user
    last_login_date { Date.current }
    login_count { 1 }
    login_streak { 1 }
    longest_login_streak { 1 }
  end
end
