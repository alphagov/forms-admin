FactoryBot.define do
  factory :organisation do
    govuk_content_id { nil }
    slug { "test-org" }
    name { slug.titleize }
    abbreviation { name.split.collect(&:chr).join }

    initialize_with do
      Organisation.create_with(govuk_content_id:, name:).find_or_initialize_by(slug:)
    end

    trait :with_signed_mou do
      after(:build) do |organisation|
        organisation.mou_signatures << (create :mou_signature_for_organisation, organisation:)
      end
    end

    trait :with_org_admin do
      with_signed_mou

      after(:build) do |organisation|
        organisation.users << create(:organisation_admin_user, organisation:)
      end
    end
  end
end
