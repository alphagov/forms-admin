FactoryBot.define do
  factory :form_document do
    form { association :form }
    tag { "draft" }

    trait :live do
      tag { "live" }
    end

    trait :archived do
      tag { "archived" }
    end

    trait :draft do
      tag { "draft" }
    end
  end
end
