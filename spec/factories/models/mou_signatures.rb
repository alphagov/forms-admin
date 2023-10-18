FactoryBot.define do
  factory :mou_signature do
    user { create(:user) }
    organisation { user.organisation }
  end
end
