FactoryBot.define do
  factory :selections_settings_form, class: "Forms::SelectionsSettingsForm" do
    selection_options { [Forms::SelectionOption.new({ name: "Option 1" }), Forms::SelectionOption.new({ name: "Option 2" })] }
    only_one_option { true }
    include_none_of_the_above { true }
  end
end
