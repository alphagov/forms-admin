FactoryBot.define do
  factory :form_document do
    form { association :form }
    tag { :draft }
  end
end
