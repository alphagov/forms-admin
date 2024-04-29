FactoryBot.define do
  factory :make_live_input, class: "Forms::MakeLiveInput" do
    confirm { %w[yes no].sample }

    form { build :form, :ready_for_live }
  end
end
