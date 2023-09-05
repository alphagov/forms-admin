FactoryBot.define do
  factory :selections_settings_form, class: "Forms::SelectionsSettingsForm" do
    selection_options { [Pages::SelectionOption.new({ name: "Option 1" }), Pages::SelectionOption.new({ name: "Option 2" })] }
    only_one_option { "true" }
    include_none_of_the_above { true }
  end
end
