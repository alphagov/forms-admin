FactoryBot.define do
  factory :group do
    name { "My Group" }
    organisation { association :organisation, id: 1, slug: "test-org" }
    creator { association :user, organisation: }
    status { :trial }
  end
end
