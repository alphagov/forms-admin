require "rails_helper"

describe Form, type: :model do
  let(:organisation) { build :organisation, id: 1 }
  let(:form) { described_class.new(id: 1, name: "Form 1", organisation:, submission_email: "") }

  describe "validations" do
    it "does not require an org" do
      form.org = nil
      expect(form).to be_valid
    end

    it "does not require an organisation_id" do
      form.organisation_id = nil
      expect(form).to be_valid
    end
  end

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
    end

    context "when a form is incomplete and should still be in draft state" do
      let(:new_form) { build :form, :new_form }

      it "returns false" do
        new_form.pages = []
        expect(new_form.ready_for_live?).to eq false
      end
    end
  end

  describe "#all_incomplete_tasks" do
    context "when a form is complete and ready to be made live" do
      let(:completed_form) { build :form, :live }

      it "returns no missing sections" do
        expect(completed_form.all_incomplete_tasks).to be_empty
      end
    end

    context "when a form is incomplete and should still be in draft state" do
      let(:new_form) { build :form, :new_form }

      it "returns a set of keys related to missing fields" do
        expect(new_form.all_incomplete_tasks).to match_array(%i[missing_pages missing_submission_email missing_privacy_policy_url missing_contact_details missing_what_happens_next])
      end
    end
  end

  describe "#all_task_statuses" do
    let(:completed_form) { build :form, :live }

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
    let(:form) { build :form, name: "Form 1", organisation:, submission_email: "", pages: non_select_from_list_pages + selection_pages_with_routes + selection_pages_without_routes }

    it "returns a list of pages that can be used as routing pages" do
      selection_pages_with_routes_excluding_last_page = selection_pages_without_routes.take(selection_pages_without_routes.length - 1)
      expect(form.qualifying_route_pages).to eq(selection_pages_with_routes_excluding_last_page)
    end
  end

  describe "#has_no_remaining_routes_available?" do
    let(:selection_pages_with_routes) do
      (1..3).map do |index|
        build :page, :with_selections_settings, id: index, position: index, routing_conditions: [(build :condition, id: index, check_page_id: index, goto_page_id: index + 2)]
      end
    end
    let(:selection_pages_without_routes) do
      (4..5).map do |index|
        build :page, :with_selections_settings, id: index, position: index, routing_conditions: []
      end
    end

    let(:form) { build :form, pages: selection_pages_with_routes }

    it "returns true if no available routes" do
      expect(form.has_no_remaining_routes_available?).to eq true
    end

    context "when there is at least one selection page with no route" do
      let(:form) { build :form, pages: selection_pages_with_routes + selection_pages_without_routes }

      it "returns false" do
        expect(form.has_no_remaining_routes_available?).to eq false
      end
    end
  end

  describe "#update_organisation_for_creator" do
    let(:headers) do
      {
        "X-API-Token" => Settings.forms_api.auth_key,
        "Content-Type" => "application/json",
      }
    end

    before do
      ActiveResource::HttpMock.reset!
    end

    it "makes patch request to the API" do
      creator_id = 123
      organisation_id = 1
      expected_path = "/api/v1/forms/update-organisation-for-creator?creator_id=123&organisation_id=1"

      ActiveResource::HttpMock.respond_to do |mock|
        mock.patch expected_path, headers, {}.to_json, 200
      end

      described_class.update_organisation_for_creator(creator_id, organisation_id)

      request = ActiveResource::Request.new(:patch, expected_path, {}, headers)
      expect(ActiveResource::HttpMock.requests).to include request
    end

    %w[creator_id organisation].each do |missing_param|
      it "does not make request to the API with #{missing_param} missing" do
        params = [missing_param == "creator_id" ? nil : 123, missing_param == "organisation" ? nil : "organisation"]

        described_class.update_organisation_for_creator(*params)

        expect(ActiveResource::HttpMock.requests).to match_array([])
      end
    end
  end

  describe "#made_live_date" do
    it "returns nil" do
      expect(form.made_live_date).to eq(nil)
    end

    context "when the form is live" do
      let(:form) { described_class.new(id: 1, name: "Form 1", organisation:, submission_email: "", live_at: Time.zone.now.to_s) }

      it "returns the date the form went live" do
        expect(form.made_live_date).to eq(form.live_at.to_date)
      end
    end
  end

  describe "#metrics_data", feature_metrics_for_form_creators_enabled: true do
    let(:form) do
      described_class.new(id: 2, live_at: Time.zone.now - 1.day)
    end

    context "when the form was made today" do
      let(:form) do
        described_class.new(id: 2, live_at: Time.zone.now)
      end

      before do
        allow(CloudWatchService).to receive(:week_submissions).and_return(0)
        allow(CloudWatchService).to receive(:week_starts).and_return(0)
      end

      it "returns 0 weekly submissions" do
        expect(form.metrics_data).to eq({ weekly_submissions: 0, weekly_starts: 0 })
      end

      it "does not call Cloudwatch" do
        form.metrics_data
        expect(CloudWatchService).not_to have_received(:week_submissions)
        expect(CloudWatchService).not_to have_received(:week_starts)
      end
    end

    context "when the form was made before today" do
      before do
        allow(CloudWatchService).to receive(:week_submissions).and_return(1255)
        allow(CloudWatchService).to receive(:week_starts).and_return(1991)
      end

      it "returns the correct number of weekly starts and submissions" do
        expect(form.metrics_data).to eq({ weekly_submissions: 1255, weekly_starts: 1991 })
      end

      it "calls the CloudWatch service" do
        form.metrics_data
        expect(CloudWatchService).to have_received(:week_submissions).once
        expect(CloudWatchService).to have_received(:week_starts).once
      end
    end

    context "when AWS credentials have not been configured" do
      before do
        allow(Sentry).to receive(:capture_exception)
        allow(CloudWatchService).to receive(:week_starts).and_raise(Aws::Errors::MissingCredentialsError)
      end

      it "returns nil and logs the exception in Sentry" do
        expect(form.metrics_data).to eq(nil)
        expect(Sentry).to have_received(:capture_exception).once
      end
    end

    context "when CloudWatch returns an error" do
      before do
        allow(CloudWatchService).to receive(:week_starts).and_raise(Aws::CloudWatch::Errors::ServiceError)
        allow(Sentry).to receive(:capture_exception)
      end

      it "returns nil and logs the exception in Sentry" do
        expect(form.metrics_data).to eq(nil)
        expect(Sentry).to have_received(:capture_exception).once
      end
    end

    context "when the metrics feature flag is off", feature_metrics_for_form_creators_enabled: false do
      it "returns nil" do
        expect(form.metrics_data).to eq(nil)
      end
    end
  end
end
