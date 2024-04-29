FactoryBot.define do
  factory :contact_details_input, class: "Forms::ContactDetailsInput" do
    contact_details_supplied { %i[supply_email supply_phone supply_link] }
    email { "example@something.gov.uk" }
    phone { "phone text" }
    link_href { "https://contact.gov.uk" }
    link_text { "contact" }
    form { build_stubbed :form, :with_pages }

    trait :with_user do
      current_user { OpenStruct.new(name: "User", email: "user@gov.uk") }
    end
  end
end
