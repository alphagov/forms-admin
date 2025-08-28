require "rails_helper"

RSpec.describe FormDocument::Content, type: :model do
  subject(:form_document_content) { described_class.new(form_as_form_document) }

  let(:form) { create :form }
  let(:form_as_form_document) { form.as_form_document }

  it "ignores any attributes that are not defined" do
    expect(described_class.new(foo: "bar").attributes).not_to include(:foo)
  end

  describe "#made_live_date" do
    context "when live_at is not set" do
      it "returns nil" do
        expect(form_document_content.made_live_date).to be_nil
      end
    end

    context "when live_at is set" do
      let(:form_as_form_document) { form.as_form_document(live_at:) }
      let(:live_at) { Time.zone.local(2024, 1, 3, 9, 10, 4) }

      it "returns the made live date" do
        expect(form_document_content.made_live_date).to eq(Time.zone.local(2024, 1, 3))
      end
    end
  end

  it "has all form attributes the original form has" do
    expected_attributes = form.attributes.except(*%w[id state external_id pages question_section_completed declaration_section_completed share_preview_completed])
    expect(form_document_content).to have_attributes(expected_attributes)
  end

  it "has a form_id" do
    expect(form_document_content).to have_attributes("form_id" => form.id)
  end

  describe "#steps" do
    it "defaults to an empty array" do
      expect(described_class.new).to have_attributes(steps: [])
    end

    context "when the form has pages" do
      let(:form) { create :form, :with_pages }

      it "converts attributes for steps to a model" do
        expect(form_document_content.steps).to all be_a FormDocument::Step
        expect(form_document_content.steps.count).to eq(form.pages.count)
      end
    end
  end
end
