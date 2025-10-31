require "rails_helper"

RSpec.describe FormCopyService do
  let(:source_form) { create(:form) }
  let(:source_form_document) { create(:form_document, :live, form: source_form) }
  let(:service) { described_class.new(source_form) }
  let(:copied_form) { service.copy }

  describe "#copy" do
    before do
      source_form_document
    end

    it "creates a new form" do
      expect {
        copied_form
      }.to change(Form, :count).by(1)

      expect(copied_form).to be_a(Form)
      expect(copied_form.id).not_to eq(source_form.id)
    end

    it "creates a new draft form document" do
      expect {
        copied_form
      }.to change(FormDocument, :count).by(1)

      new_form_document = copied_form.draft_form_document
      expect(new_form_document).to be_present
      expect(new_form_document.tag).to eq("draft")
    end

    it "copies the content from the source form document" do
      content = { "name" => "Test Form", "pages" => [] }
      source_form_document.update!(content:)

      new_form_document = copied_form.draft_form_document
      expect(new_form_document.content).to eq(content)
    end

    it "copies the language from the source form document" do
      source_form_document.update!(language: "cy")

      new_form_document = copied_form.draft_form_document
      expect(new_form_document.language).to eq("cy")
    end

    it "returns the new form" do
      expect(copied_form).to be_a(Form)
      expect(copied_form).to be_persisted
      expect(copied_form.id).not_to eq(source_form.id)
    end

    it "associates the draft form document with the new form" do
      new_form_document = copied_form.draft_form_document
      expect(new_form_document.form).to eq(copied_form)
    end

    context "when copying from a draft form document" do
      let(:source_form_document) { create(:form_document, :draft, form: source_form) }

      it "creates a draft form document for the new form" do
        new_form_document = copied_form.draft_form_document
        expect(new_form_document.tag).to eq("draft")
      end
    end

    context "when copying from an archived form document" do
      let(:source_form_document) { create(:form_document, :archived, form: source_form) }

      it "creates a draft form document for the new form" do
        new_form_document = copied_form.draft_form_document
        expect(new_form_document.tag).to eq("draft")
      end
    end
  end
end
