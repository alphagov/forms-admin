FactoryBot.define do
  factory :membership do
    user
    group
    added_by { association :user }
    role { :editor }
  end
end
