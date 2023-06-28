FactoryBot.define do
  factory :organisation do
    govuk_content_id { nil }
    slug { "test-org" }
    name { ActiveSupport::Inflector.titleize slug }

    initialize_with do
      Organisation.create_with(govuk_content_id:, name:).find_or_initialize_by(slug:)
    end
  end
end
