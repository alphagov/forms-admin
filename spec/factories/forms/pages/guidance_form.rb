FactoryBot.define do
  factory :guidance_form, class: "Pages::GuidanceForm" do
    page_heading { nil }
    guidance_markdown { nil }
    draft_question { nil }

    trait :with_guidance do
      page_heading { Faker::Quote.yoda }
      guidance_markdown { "## List of items \n\n\n #{Faker::Markdown.ordered_list}" }
    end
  end
end
