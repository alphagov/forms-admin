FactoryBot.define do
  factory :group do
    sequence(:name) { |n| "Group #{n}" }
    organisation { association :organisation, id: 1, slug: "test-org" }
    creator { association :user, organisation: }
    status { :trial }

    trait :org_has_org_admin do
      organisation { association :organisation, :with_org_admin, id: 1, slug: "test-org" }
    end
  end
end
