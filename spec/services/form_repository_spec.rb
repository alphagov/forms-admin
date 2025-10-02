require "rails_helper"

describe FormRepository do
  describe "#save!" do
    let(:form) { create(:form_record, name: "database name", creator_id: 3) }

    it "saves the form to the the database" do
      form.name = "new name"

      expect {
        described_class.save!(form)
      }.to change { Form.find(form.id).name }.to("new name")
    end

    it "returns a form record" do
      expect(described_class.save!(form)).to be_a(Form)
    end

    context "when the form is live" do
      let(:form) { create(:form, :live) }
      let(:updated_form_resource) { build(:form_resource, :live, id: form.id) }

      it "changes the form's state to live_with_draft" do
        expect {
          described_class.save!(form)
        }.to change { Form.find(form.id).state }.to("live_with_draft")
      end
    end

    context "when the form is archived" do
      let(:form) { create(:form, :archived) }
      let(:updated_form_resource) { build(:form_resource, :archived, id: form.id) }

      it "changes the form's state to archived_with_draft" do
        expect {
          described_class.save!(form)
        }.to change { Form.find(form.id).state }.to("archived_with_draft")
      end
    end
  end

  describe "#archive!" do
    let(:form) { create(:form_record, :live) }

    it "archives the form to the database" do
      expect {
        described_class.archive!(form)
      }.to change { Form.find(form.id).state }.to("archived")
    end

    it "returns a Form object" do
      expect(described_class.archive!(form)).to be_a(Form)
    end
  end

  describe "#destroy" do
    let!(:form) { create(:form_record) }

    it "removes the form from the database" do
      expect {
        described_class.destroy(form)
      }.to change(Form, :count).by(-1)
    end

    it "returns a Form object" do
      expect(described_class.destroy(form)).to be_a(Form)
    end

    it "returns the deleted form" do
      expect(described_class.destroy(form)).to eq form
    end

    context "when the form has already been deleted" do
      it "does not raise an error" do
        described_class.destroy(form)

        expect {
          described_class.destroy(form)
        }.not_to raise_error
      end
    end
  end

  describe "#pages" do
    let(:form) { create(:form_record, :with_pages) }

    it "returns page records" do
      expect(described_class.pages(form).first).to be_a(Page)
    end
  end
end
