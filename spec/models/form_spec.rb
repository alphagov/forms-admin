require "rails_helper"

describe Form do
  let(:form) { described_class.new(id: 1, name: "Form 1", org: "Test org", submission_email: "") }

  describe "#status" do
    context "when form has not been made live" do
      it "returns 'draft'" do
        form.has_live_version = false
        expect(form.status).to eq :draft
      end
    end

    context "when form has been made live" do
      it "returns 'live'" do
        form.has_live_version = true
        expect(form.status).to eq :live
      end
    end
  end

  describe "#ready_for_live?" do
    context "when a form is complete and ready to be made live" do
      let(:completed_form) { build :form, :live }

      it "returns true" do
        expect(completed_form.ready_for_live?).to eq true
      end

      it "returns no missing fields" do
        results = completed_form
        results.ready_for_live?

        expect(results.missing_sections).to be_empty
      end
    end

    context "when a form is incomplete and should still be in draft state" do
      let(:new_form) { build :form, :new_form }

      it "returns false" do
        new_form.pages = []
        expect(new_form.ready_for_live?).to eq false
      end

      it "returns a set of keys related to missing fields" do
        new_form.pages = []
        results = new_form
        results.ready_for_live?

        expect(results.missing_sections).to eq %i[missing_pages missing_submission_email missing_privacy_policy_url missing_contact_details missing_what_happens_next]
      end
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
    let(:completed_form) { build :form, :live }

    context "with an existing page" do
      let(:page)  { completed_form.pages.first }

      it "returns the page position" do
        expect(completed_form.page_number(page)).to eq(1)
      end
    end

    context "with an new page" do
      let(:page)  { build :page }

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
        build :page, id: index, position: index
      end
    end
    let(:selection_pages_with_routes) do
      (4..5).map do |index|
        build :page, :with_selections_settings, id: index, position: index, routing_conditions: [(build :condition, id: index, check_page_id: index, goto_page_id: index + 2)]
      end
    end
    let(:selection_pages_without_routes) do
      (6..9).map do |index|
        build :page, :with_selections_settings, id: index, position: index, routing_conditions: []
      end
    end
    let(:form) { build :form, name: "Form 1", org: "Test org", submission_email: "", pages: non_select_from_list_pages + selection_pages_with_routes + selection_pages_without_routes }

    it "returns a list of pages that can be used as routing pages" do
      selection_pages_with_routes_excluding_last_page = selection_pages_without_routes.take(selection_pages_without_routes.length - 1)
      expect(form.qualifying_route_pages).to eq(selection_pages_with_routes_excluding_last_page)
    end
  end

  describe "#update_org_for_creator" do
    let(:headers) do
      {
        "X-API-Token" => Settings.forms_api.auth_key,
        "Content-Type" => "application/json",
      }
    end

    it "makes patch request to the API" do
      creator_id = 123
      org = "org"
      expected_path = "/api/v1/forms/update-org-for-creator?creator_id=123&org=org"

      ActiveResource::HttpMock.respond_to do |mock|
        mock.patch expected_path, headers, {}.to_json, 204
      end

      described_class.update_org_for_creator(creator_id, org)

      request = ActiveResource::Request.new(:patch, expected_path, {}, headers)
      expect(ActiveResource::HttpMock.requests).to include request
    end
  end
end
