require "rails_helper"

RSpec.describe Form, type: :model do
  subject(:form) { described_class.new }

  describe "factory" do
    it "has a valid factory" do
      form = create :form_record
      expect(form).to be_valid
    end

    it "has a ready for live trait" do
      form = build :form_record, :ready_for_live
      expect(form.ready_for_live).to be true
      expect(form.incomplete_tasks).to be_empty
      expect(form.task_statuses).to include(
        declaration_status: :completed,
        make_live_status: :not_started,
        name_status: :completed,
        pages_status: :completed,
        privacy_policy_status: :completed,
        support_contact_details_status: :completed,
        what_happens_next_status: :completed,
      )
    end

    it "has a live trait" do
      form = build :form_record, :live
      expect(form.state).to eq "live"
    end

    it "has a live with draft trait" do
      form = build :form_record, :live_with_draft
      expect(form.state).to eq "live_with_draft"
    end

    it "has an archived trait" do
      form = build :form_record, :archived
      expect(form.state).to eq "archived"
    end

    it "has an archived with draft trait" do
      form = build :form_record, :archived_with_draft
      expect(form.state).to eq "archived_with_draft"
    end

    it "has a ready for routing trait" do
      form = create :form_record, :ready_for_routing
      expect(form.pages).to be_present
      expect(form.pages.map(&:position)).to eq [1, 2, 3, 4, 5]
    end

    it "has a missing pages trait" do
      form = build :form_record, :missing_pages
      expect(form.incomplete_tasks).to eq %i[missing_pages]
    end
  end

  describe "validations" do
    it "validates" do
      form.name = "test"
      expect(form).to be_valid
    end

    it "requires name" do
      expect(form).to be_invalid
      expect(form.errors[:name]).to include("can't be blank")
    end

    context "when the form has validation errors" do
      let(:form) { create :form_record, pages: [routing_page, goto_page] }
      let(:routing_page) do
        new_routing_page = create :page_record
        new_routing_page.routing_conditions = [(create :condition_record, routing_page_id: new_routing_page.id, goto_page_id: nil)]
        new_routing_page
      end
      let(:goto_page) { create :page_record }
      let(:goto_page_id) { goto_page.id }

      context "when the form is marked complete" do
        it "returns invalid" do
          form.question_section_completed = true

          expect(form).to be_invalid
          expect(form.errors[:base]).to include("Form has routing validation errors")
        end
      end

      context "when the form is not marked complete" do
        it "returns valid" do
          form.question_section_completed = false
          expect(form).to be_valid
        end
      end

      context "when the payment url is not a url" do
        it "returns invalid" do
          form.payment_url = "not a url"
          expect(form).to be_invalid
        end
      end

      context "when the payment url is a url" do
        it "returns valid" do
          form.payment_url = "https://example.com/"
          expect(form).to be_valid
        end
      end

      context "when there is no payment url" do
        it "returns valid" do
          form.payment_url = nil
          expect(form).to be_valid
        end
      end

      context "when there is no submission type" do
        it "returns invalid" do
          form.submission_type = nil
          expect(form).to be_invalid
        end
      end
    end
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

  describe "#has_routing_errors" do
    let(:form) { create :form_record, pages: [routing_page, goto_page] }
    let(:routing_page) do
      new_routing_page = create :page_record
      new_routing_page.routing_conditions = [(create :condition_record, routing_page_id: new_routing_page.id, goto_page_id:)]
      new_routing_page
    end
    let(:goto_page) { create :page_record }
    let(:goto_page_id) { goto_page.id }

    context "when there are no validation errors" do
      it "returns false" do
        expect(form.has_routing_errors).to be false
      end
    end

    context "when there are validation errors" do
      let(:goto_page_id) { nil }

      it "returns true" do
        expect(form.has_routing_errors).to be true
      end
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

  describe "#destroy" do
    let(:form) { create :form_record }

    context "when form is in a group" do
      it "destroys the group" do
        group = create :group
        GroupForm.create!(group:, form_id: form.id)

        ActiveResource::HttpMock.respond_to do |mock|
          mock.post "/api/v1/forms", post_headers, { id: 1 }.to_json, 200
          mock.delete "/api/v1/forms/1", delete_headers, nil, 204
        end

        # form must exist for ActiveResource to delete it
        form.save!

        expect {
          form.destroy
        }.to change(GroupForm, :count).by(-1)

        expect(GroupForm.find_by(form_id: form.id)).to be_nil
      end
    end
  end

  describe "#group" do
    let(:form) { create :form_record }

    it "returns nil if form is not in a group" do
      expect(form.group).to be_nil
    end

    it "returns the group if form is in a group" do
      group = create :group
      GroupForm.create!(form_id: form.id, group_id: group.id)
      expect(form.group).to eq group
    end
  end

  describe "#move_to_group" do
    context "when the form is in an existing group" do
      let(:form) { create(:form_record) }
      let(:old_group) { create :group, name: "Group 1" }
      let(:group_form) { GroupForm.find_by!(form_id: form.id) }

      before do
        GroupForm.create!(form_id: form.id, group: old_group)
      end

      context "when the user tries to move the form to a different group" do
        let(:new_group) { create :group, name: "Group 2" }

        it "moves the form" do
          expect { form.move_to_group(new_group.external_id) }.to change { GroupForm.find_by!(form_id: form.id).reload.group.id }.to(new_group.id)
        end
      end

      context "when the user tries to move the form to its existing group" do
        it "leaves the form where it is" do
          expect { form.move_to_group(old_group.external_id) }.not_to(change { group_form.reload.group.id })
        end
      end

      context "when the new group does not exist" do
        it "throws an ActiveRecord::RecordNotFound error" do
          expect { form.move_to_group("some_nonexistent_external_id") }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end
    end
  end
end
