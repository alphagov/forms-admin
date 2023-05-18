FactoryBot.define do
  factory :user, class: "User" do
    name { Faker::Name.name }
    email { Faker::Internet.email(name:, domain: "example.gov.uk") }
    uid { Faker::Internet.uuid }
    role { :editor }
    has_access { true }

    trait :with_super_admin do
      role { :super_admin }
    end

    organisation_slug { "test-org" }
    organisation { association :organisation, slug: organisation_slug }

    after(:build) do |user|
      if user.organisation.present?
        user.organisation_slug = user.organisation.slug
        user.organisation_content_id = user.organisation.content_id
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
