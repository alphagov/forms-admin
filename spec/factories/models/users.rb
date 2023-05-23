FactoryBot.define do
  factory :user, class: "User" do
    name { Faker::Name.name }
    email { Faker::Internet.email(name:, domain: "example.gov.uk") }
    uid { Faker::Internet.uuid }
    provider { "factory_bot" }
    role { :editor }
    has_access { true }

    trait :with_super_admin do
      role { :super_admin }
    end

    trait :with_trial do
      role { :trial }
    end

    organisation_slug { "test-org" }
    organisation { association :organisation, slug: organisation_slug }

    after(:build) do |user|
      if user.organisation.present?
        # set deprecated attributes to nil to make sure no code is accidentally relying on them
        user.organisation_slug = nil
        user.organisation_content_id = nil
      end
    end

    trait :with_unknown_org do
      organisation { nil }
      organisation_slug { "unknown-org" }
      organisation_content_id { Faker::Internet.uuid }
    end

    trait :with_no_org do
      organisation { nil }
      organisation_slug { nil }
      organisation_content_id { nil }
    end
  end
end
