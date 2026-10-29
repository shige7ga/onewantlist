FactoryBot.define do
  factory :memo do
    association :user
    content { "今度やってみたいこと" }
  end
end
