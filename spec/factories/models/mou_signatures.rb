FactoryBot.define do
  factory :mou_signature do
    agreed_at { Faker::Time.between(from: 1.year.ago, to: Time.zone.now) }
    user { create(:user) }
    organisation { user.organisation }
  end
end
