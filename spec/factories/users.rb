FactoryBot.define do
  factory :user do
    name { "test_user" }
    email { "test@example.com" }
    password { "password" }
    password_confirmation { "password" }

    trait :tester do
      role { :tester }
    end

    trait :admin do
      role { :admin }
    end
  end
end
