FactoryBot.define do
  factory :user, class: "User" do
    email { Faker::Internet.email(domain: "example.gov.uk") }
    name { Faker::Name.name }
    uid { Faker::Internet.uuid }
    organisation_slug { "test-org" }
    role { :editor }

    trait :with_super_admin do
      role { :super_admin }
    end
  end
end
