require "rails_helper"

RSpec.describe FormCopyService do
  let(:source_form) { create(:form) }
  let(:source_form_document) { create(:form_document, :live, form: source_form) }
  let(:service) { described_class.new(source_form) }

  describe "#copy" do
    it "creates a new form" do
      expect {
        service.copy
      }.to change(Form, :count).by(1)
    end

    it "creates a new draft form document" do
      expect {
        service.copy
      }.to change(FormDocument, :count).by(1)

      new_form_document = FormDocument.last
      expect(new_form_document.tag).to eq("draft")
    end

    it "copies the content from the source form document" do
      content = { "name" => "Test Form", "pages" => [] }
      source_form_document.update!(content:)

      service.copy

      new_form_document = FormDocument.last
      expect(new_form_document.content).to eq(content)
    end

    it "copies the language from the source form document" do
      source_form_document.update!(language: "cy")

      service.copy

      new_form_document = FormDocument.last
      expect(new_form_document.language).to eq("cy")
    end

    it "returns the new form" do
      result = service.copy

      expect(result).to be_a(Form)
      expect(result).to eq(Form.last)
    end

    it "associates the draft form document with the new form" do
      result = service.copy

      new_form_document = FormDocument.last
      expect(new_form_document.form).to eq(result)
    end

    context "when copying from a draft form document" do
      let(:source_form_document) { create(:form_document, :draft, form: source_form) }

      before do
        service.copy
      end

      it "creates a draft form document for the new form" do
        new_form_document = FormDocument.last
        expect(new_form_document.tag).to eq("draft")
      end
    end

    context "when copying from an archived form document" do
      let(:source_form_document) { create(:form_document, :archived, form: source_form) }

      before do
        service.copy
      end

      it "creates a draft form document for the new form" do
        new_form_document = FormDocument.last
        expect(new_form_document.tag).to eq("draft")
      end
    end
  end
end
