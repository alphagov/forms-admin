require "rails_helper"

RSpec.describe Form, type: :model do
  subject(:form) { described_class.new }

  it "has a valid factory" do
    form = create :form_record
    expect(form).to be_valid
  end

  describe "external_id" do
    it "intialises a new form with an external id matching its id" do
      form = create :form_record
      expect(form.external_id).to eq(form.id.to_s)
    end
  end

  describe "page scope" do
    it "returns pages in position order" do
      form = create :form_record

      page_a = create :page_record, form_id: form.id, position: 2
      page_b = create :page_record, form_id: form.id, position: 1

      expect(form.pages).to eq([page_b, page_a])
    end
  end

  describe "FormStateMachine" do
    describe "#create_draft_from_live_form!" do
      let(:form) { create :form_record, :live }

      it "sets share_preview_completed to false" do
        expect { form.create_draft_from_live_form! }.to change(form, :share_preview_completed).to(false)
      end
    end

    describe "#create_draft_from_archived_form!" do
      let(:form) { create :form_record, :archived }

      it "sets share_preview_completed to false" do
        expect { form.create_draft_from_archived_form! }.to change(form, :share_preview_completed).to(false)
      end
    end
  end

  describe "#has_draft_version" do
    let(:live_form) { create(:form_record, :live) }
    let(:new_form) { create(:form_record) }

    it "returns true if form is draft" do
      new_form.state = :draft
      expect(new_form.has_draft_version).to be(true)
    end

    it "returns false if form is live and no edits" do
      live_form.state = :live
      expect(live_form.has_draft_version).to be(false)
    end

    it "returns true if form is live with a draft" do
      live_form.state = :live_with_draft
      live_form.update!(name: "Form (edited)")

      expect(live_form.has_draft_version).to be(true)
    end

    it "returns true if form has been made live and one of its pages has been edited" do
      live_form.pages[0].question_text = "Edited question"
      live_form.pages[0].save_and_update_form

      expect(live_form.has_draft_version).to be(true)
    end

    it "returns true if form is archived with a draft" do
      live_form.state = :archived_with_draft

      expect(live_form.has_draft_version).to be(true)
    end
  end

  describe "#has_live_version" do
    let(:live_form) { create(:form_record, :live) }
    let(:new_form) { create(:form_record) }

    it "returns false if form has not been made live before" do
      expect(new_form.has_live_version).to be(false)
    end

    it "returns true if form has been made live" do
      expect(live_form.has_live_version).to be(true)
    end
  end

  describe "#has_been_archived" do
    let(:live_form) { create(:form_record, :live) }
    let(:archived_form) { create(:form_record, state: :archived) }
    let(:archived_with_draft_form) { create(:form_record, state: :archived_with_draft) }

    it "returns false if form is live" do
      expect(live_form.has_been_archived).to be(false)
    end

    it "returns true if form has been archived" do
      expect(archived_form.has_been_archived).to be(true)
    end

    it "returns true if form has been archived with draft" do
      expect(archived_with_draft_form.has_been_archived).to be(true)
    end
  end

  describe "#ready_for_live" do
    context "when a form is complete and ready to be made live" do
      let(:completed_form) { create(:form_record, :live) }

      it "returns true" do
        expect(completed_form.ready_for_live).to be true
      end
    end

    context "when a form is incomplete and should still be in draft state" do
      let(:new_form) { build :form_record, :new_form }

      [
        {
          attribute: :pages,
          attribute_value: [],
        },
        {
          attribute: :what_happens_next_markdown,
          attribute_value: nil,
        },
        {
          attribute: :privacy_policy_url,
          attribute_value: nil,
        },
        {
          attribute: :support_email,
          attribute_value: nil,
        },
      ].each do |scenario|
        it "returns false if #{scenario[:attribute]} is missing" do
          new_form.send("#{scenario[:attribute]}=", scenario[:attribute_value])
          expect(new_form.ready_for_live).to be false
        end
      end
    end
  end

  describe "submission type" do
    describe "enum" do
      it "returns a list of submission types" do
        expect(described_class.submission_types.keys).to eq(%w[email email_with_csv s3])
        expect(described_class.submission_types.values).to eq(%w[email email_with_csv s3])
      end
    end
  end
end
