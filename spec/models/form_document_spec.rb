require "rails_helper"

RSpec.describe FormDocument, type: :model do
  it "is valid with valid attributes" do
    form_document = build(:form_document)
    expect(form_document).to be_valid
  end

  it "is invalid without a form" do
    form_document = build(:form_document, form: nil)
    expect(form_document).not_to be_valid
  end

  it "is invalid without a tag" do
    form_document = build(:form_document, tag: nil)
    expect(form_document).not_to be_valid
  end

  it "has a default created_at and updated_at" do
    travel_to Time.zone.local(2023, 10, 1, 10, 0, 0) do
      form_document = create(:form_document, :live)

      expect(form_document.created_at).to eq(Time.zone.now)
      expect(form_document.updated_at).to eq(Time.zone.now)
    end
  end

  it "belongs to a Form" do
    form_document = build(:form_document)

    expect(form_document.form).to be_a(Form)
  end

  it "tags must be unique for a given form" do
    form_document = create(:form_document, tag: "live")
    expect { create(:form_document, form: form_document.form, tag: "live") }.to raise_error(ActiveRecord::RecordNotUnique)
  end
end
