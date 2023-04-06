FactoryBot.define do
  factory :user, class: "User" do
    email { Faker::Internet.email(domain: "example.gov.uk") }
    name { Faker::Name.name }
    uid { Faker::Internet.uuid }
    organisation_slug { "test-org" }
    role { :editor }

    trait :super_admin do
      # TODO: remove this once we have a super_admin role
      email { Faker::Internet.email(domain: "digital.cabinet-office.gov.uk") }
      # Phase 2, included already because it makes testing for super_admin? now
      # easier, rather than adding more methods to the model which will change
      # in phase 2
      role { :super_admin }
    end
  end
end
