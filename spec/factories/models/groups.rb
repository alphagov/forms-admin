FactoryBot.define do
  factory :group do
    sequence(:name) { |n| "Group #{n}" }
    organisation { association :organisation, id: 1, slug: "test-org" }
    creator { association :user, organisation: }
    status { :trial }
    welsh_enabled { false }
    external_id { SecureRandom.base58(8) }

    trait :org_has_org_admin do
      organisation { association :organisation, :with_org_admin, id: 1, slug: "test-org" }
    end

    trait :with_welsh_enabled do
      welsh_enabled { true }
    end
  end
end
