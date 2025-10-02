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
end
