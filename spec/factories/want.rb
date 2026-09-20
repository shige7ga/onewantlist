FactoryBot.define do
  factory :want do
    content { "富士山を登る" }
    association :owner, factory: :user
  end
end
