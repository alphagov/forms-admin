FactoryBot.define do
  factory :user, class: "User" do
    name { Faker::Name.name }
    email { Faker::Internet.email(name:, domain: "example.gov.uk") }
    uid { Faker::Internet.uuid }
    provider { "factory_bot" }
    role { :standard }
    has_access { true }
    terms_agreed_at { Time.zone.now }

    factory :basic_auth_user do
      provider { "basic_auth" }
    end

    factory :super_admin_user do
      role { :super_admin }
    end

    factory :organisation_admin_user do
      role { :organisation_admin }
      org_has_signed_mou
    end

    organisation { association :organisation, id: 1, slug: "test-org" }

    trait :org_has_signed_mou do
      organisation { association :organisation, :with_signed_mou, id: 1, slug: "test-org" }
    end

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

    trait :with_no_name do
      name { nil }
    end
  end
end
