FactoryBot.define do
  factory :want do
    content { "富士山を登る" }
    association :user

    trait :with_details do
      status { :in_progress }
      due_date { 1.week.from_now }
    end
  end
end
