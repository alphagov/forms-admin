FactoryBot.define do
  factory :make_live_form, class: "Forms::MakeLiveForm" do
    confirm_make_live { %w[made_live not_made_live].sample }

    form { build :form, :with_pages, :ready_for_live }
  end
end
