FactoryBot.define do
  factory :bulk_options_input, class: "Pages::Selection::BulkOptionsInput" do
    bulk_selection_options { "Option 1\nOption 2" }
    include_none_of_the_above { "true" }
    draft_question { build :draft_question, answer_type: "selection", answer_settings: { only_one_option: "true", selection_options: [] } }
  end
end
