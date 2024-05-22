FactoryBot.define do
  factory :mou_signature do
    user { create(:user) }
    organisation { user.organisation }

    factory :mou_signature_for_organisation do
      organisation
      user { create(:user, organisation:) }
    end
  end
end
