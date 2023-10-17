FactoryBot.define do
  factory :guidance_form, class: "Pages::GuidanceForm" do
    page_heading { Faker::Quote.yoda.truncate(250) }
    guidance_markdown { "## List of items \n\n\n #{Faker::Markdown.ordered_list}" }
    draft_question { build :draft_question }
  end
end
