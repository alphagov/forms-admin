FactoryBot.define do
  factory :organisation do
    govuk_content_id { nil }
    slug { "test-org" }
    name { slug.titleize }
    abbreviation { name.split.collect(&:chr).join }

    initialize_with do
      Organisation.create_with(govuk_content_id:, name:).find_or_initialize_by(slug:)
    end
  end
end
