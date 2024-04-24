FactoryBot.define do
  factory :make_live_form, class: "Forms::MakeLiveForm" do
    confirm { %w[yes no].sample }

    form { build :form, :ready_for_live }
  end
end
