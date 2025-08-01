require "rails_helper"

describe Api::V1::FormResource, type: :model do
  let(:id) { 1 }
  let(:form) { described_class.new(id:, name: "Form 1", submission_email: "") }

  describe "factory" do
    it "has a valid factory" do
      form = build :form_resource
      expect(form).to be_valid
    end

    it "links pages together with the position and next_page attributes" do
      pages = build_list(:page_resource, 5) { |page, index| page.id = index + 1 }
      build(:form_resource, pages:)
      expect(pages.map(&:position)).to eq [1, 2, 3, 4, 5]
      expect(pages.map(&:next_page)).to eq [2, 3, 4, 5, nil]
    end
  end

  describe "#database_attributes" do
    it "includes attributes for ActiveRecord Form model" do
      expect(form.database_attributes).to eq({
        "id" => 1,
        "external_id" => "1",
        "name" => "Form 1",
        "submission_email" => "",
      })
    end

    it "does not include attributes not in the ActiveRecord Form model" do
      form = described_class.new(id:, name: "Form 1", incomplete_tasks: %i[missing_pages missing_privacy_policy])
      expect(form.database_attributes).not_to include(
        :incomplete_tasks,
      )
    end
  end

  describe "#destroy" do
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

  describe "#ready_for_live?" do
    context "when a form is complete and ready to be made live" do
      let(:completed_form) { build :form_resource, :live }

      it "returns true" do
        expect(completed_form.ready_for_live?).to be true
      end
    end

    context "when a form is incomplete and should still be in draft state" do
      let(:new_form) { build :form_resource, :new_form }

      it "returns false" do
        new_form.pages = []
        expect(new_form.ready_for_live?).to be false
      end
    end
  end

  describe "#all_incomplete_tasks" do
    context "when a form is complete and ready to be made live" do
      let(:completed_form) { build :form_resource, :live }

      it "returns no missing sections" do
        expect(completed_form.all_incomplete_tasks).to be_empty
      end
    end

    context "when a form is incomplete and should still be in draft state" do
      let(:new_form) { build :form_resource, :new_form }

      it "returns a set of keys related to missing fields" do
        expect(new_form.all_incomplete_tasks).to match_array(%i[missing_pages missing_submission_email missing_privacy_policy_url missing_contact_details missing_what_happens_next share_preview_not_completed])
      end
    end
  end

  describe "#all_task_statuses" do
    let(:completed_form) { build :form_resource, :live }

    it "returns a hash with each of the task statuses" do
      expected_hash = {
        name_status: :completed,
        pages_status: :completed,
        declaration_status: :completed,
        what_happens_next_status: :completed,
        submission_email_status: :completed,
        confirm_submission_email_status: :completed,
        privacy_policy_status: :completed,
        support_contact_details_status: :completed,
        make_live_status: :not_started,
      }
      expect(completed_form.all_task_statuses).to eq expected_hash
    end
  end

  describe "#email_confirmation_status" do
    it "returns :not_started" do
      expect(form.email_confirmation_status).to eq(:not_started)
    end

    it "with submission_email set and no FormSubmissionEmail, returns :email_set_without_confirmation" do
      form.submission_email = "test@example.gov.uk"
      expect(form.email_confirmation_status).to eq(:email_set_without_confirmation)
    end

    it "with FormSubmissionEmail code returns :sent" do
      create :form_submission_email, form_id: form.id, temporary_submission_email: "test@example.gov.uk", confirmation_code: "123456"
      expect(form.email_confirmation_status).to eq(:sent)
    end

    it "with FormSubmissionEmail with no code returns :confirmed" do
      create :form_submission_email, form_id: form.id, temporary_submission_email: "test@example.gov.uk", confirmation_code: ""
      expect(form.email_confirmation_status).to eq(:confirmed)
    end

    it "with FormSubmissionEmail with code and email matches forms returns :confirmed" do
      form.submission_email = "test@example.gov.uk"
      create :form_submission_email, form_id: form.id, temporary_submission_email: "test@example.gov.uk", confirmation_code: "123456"
      expect(form.email_confirmation_status).to eq(:confirmed)
    end
  end

  describe "#page_number" do
    let(:completed_form) { build :form_resource, :live }

    context "with an existing page" do
      let(:page) { completed_form.pages.first }

      it "returns the page position" do
        expect(completed_form.page_number(page)).to eq(1)
      end
    end

    context "with an new page" do
      let(:page) { build :page_resource }

      it "returns the position for a new page" do
        expect(completed_form.page_number(page)).to eq(completed_form.pages.count + 1)
      end
    end

    context "with an unspecified page" do
      it "returns the position for a new page" do
        expect(completed_form.page_number(nil)).to eq(completed_form.pages.count + 1)
      end
    end
  end

  describe "#qualifying_route_pages" do
    let(:non_select_from_list_pages) do
      (1..3).map do |index|
        build :page_resource, id: index, position: index
      end
    end

    let(:selection_pages_with_routes) do
      (4..5).map do |index|
        build :page_resource, :with_selection_settings, id: index, position: index, routing_conditions: [(build :condition_resource, id: index, routing_page_id: index, check_page_id: index, goto_page_id: index + 2)]
      end
    end

    let(:selection_pages_without_routes) do
      (6..9).map do |index|
        build :page_resource, :with_selection_settings, id: index, position: index, routing_conditions: []
      end
    end

    let(:selection_pages_with_secondary_skips) do
      (10..12).map do |index|
        build :page_resource, :with_selection_settings, id: index, position: index, routing_conditions: [(build :condition_resource, id: index, routing_page_id: index, check_page_id: index, goto_page_id: index + 2)]
      end
    end

    let!(:secondary_skip_pages) do
      (13..16).map do |index|
        build :page_resource, :with_selection_settings, id: index, position: index, routing_conditions: [(build :condition_resource, id: index, routing_page_id: index, check_page_id: index - 3, goto_page_id: index + 2)]
      end
    end

    let(:form) { build :form_resource, name: "Form 1", submission_email: "", pages: non_select_from_list_pages + selection_pages_with_routes + selection_pages_without_routes + selection_pages_with_secondary_skips + secondary_skip_pages }

    before do
      allow(form).to receive(:group).and_return(build(:group))
    end

    it "returns a list of pages that can be used as routing pages" do
      selection_pages_excluding_last_page = (selection_pages_with_routes + selection_pages_without_routes)

      expect(form.qualifying_route_pages).to match_array(selection_pages_excluding_last_page)
    end
  end

  describe "#has_no_remaining_routes_available?" do
    let(:selection_pages_with_routes) do
      (1..3).map do |index|
        build :page_resource, :with_selection_settings, id: index, position: index, routing_conditions: [(build :condition_resource, id: index, check_page_id: index, goto_page_id: index + 2)]
      end
    end
    let(:secondary_skip_pages) do
      (4..6).map do |index|
        build :page_resource, :with_simple_answer_type, id: index, position: index, routing_conditions: [(build :condition_resource, id: index, routing_page_id: index, check_page_id: index - 3, goto_page_id: index + 2)]
      end
    end
    let(:selection_pages_without_routes) do
      (7..8).map do |index|
        build :page_resource, :with_selection_settings, id: index, position: index, routing_conditions: []
      end
    end

    let(:form) { build :form_resource, pages: selection_pages_with_routes + secondary_skip_pages }

    before do
      allow(form).to receive(:group).and_return(build(:group))
    end

    it "returns true if no available routes" do
      expect(form.has_no_remaining_routes_available?).to be true
    end

    context "when there is at least one selection page with no route" do
      let(:form) { build :form_resource, pages: selection_pages_with_routes + selection_pages_without_routes }

      before do
        allow(form).to receive(:group).and_return(build(:group))
      end

      it "returns false" do
        expect(form.has_no_remaining_routes_available?).to be false
      end
    end
  end

  describe "#made_live_date" do
    it "returns nil" do
      expect(form.made_live_date).to be_nil
    end

    context "when the form is live" do
      let(:form) { described_class.new(id: 1, name: "Form 1", submission_email: "", live_at: Time.zone.now.to_s) }

      it "returns the date the form went live" do
        expect(form.made_live_date).to eq(form.live_at.to_date)
      end
    end
  end

  describe "#is_live?" do
    it "returns true if state live" do
      form.state = :live
      expect(form.is_live?).to be true
    end

    it "returns true if state live with draft" do
      form.state = :live_with_draft
      expect(form.is_live?).to be true
    end

    it "returns false if state draft" do
      form.state = :draft
      expect(form.is_live?).to be false
    end
  end

  describe "#is_archived?" do
    it "returns true if state archived" do
      form.state = :archived
      expect(form.is_archived?).to be true
    end

    it "returns true if state archived with draft" do
      form.state = :archived_with_draft
      expect(form.is_archived?).to be true
    end

    it "returns false if state draft" do
      form.state = :draft
      expect(form.is_archived?).to be false
    end

    it "returns false if state live" do
      form.state = :live
      expect(form.is_archived?).to be false
    end

    it "returns false if state live_with_draft" do
      form.state = :live_with_draft
      expect(form.is_archived?).to be false
    end

    context "when state value is a string" do
      it "returns true if state archived" do
        form.state = "archived"
        expect(form.is_archived?).to be true
      end
    end
  end

  describe "#group" do
    it "returns nil if form is not in a group" do
      expect(form.group).to be_nil
    end

    it "returns the group if form is in a group" do
      group = create :group
      GroupForm.create!(form_id: form.id, group_id: group.id)
      expect(form.group).to eq group
    end
  end

  describe "#file_upload_question_count" do
    let(:pages) do
      pages = build_list :page_resource, 3, answer_type: :file
      Page::ANSWER_TYPES.each do |answer_type|
        pages.push(build(:page_resource, answer_type:))
      end
      pages
    end
    let(:form) { build :form_resource, pages: }

    it "returns the number of file upload questions" do
      expect(form.file_upload_question_count).to eq(4)
    end
  end
end
