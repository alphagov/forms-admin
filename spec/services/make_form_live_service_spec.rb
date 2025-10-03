require "rails_helper"

describe MakeFormLiveService do
  let(:make_form_live_service) { described_class.call(current_form:, current_user:) }
  let(:current_form) { create :form, :ready_for_live }
  let(:live_form_document) { current_form.live_form_document }
  let(:current_user) { build :user }

  describe "#make_live" do
    it "makes the form live" do
      expect {
        make_form_live_service.make_live
      }.to change(current_form, :state).to("live")
    end

    it "does not call the SubmissionEmailMailer" do
      expect(SubmissionEmailMailer).not_to receive(:alert_email_change)
      make_form_live_service.make_live
    end

    context "when draft form has live version" do
      let(:current_form) { create :form, :live_with_draft }

      context "when submission email has not been changed" do
        it "does not call the SubmissionEmailMailer" do
          expect(SubmissionEmailMailer).not_to receive(:alert_email_change)

          make_form_live_service.make_live
        end
      end

      context "when submission email has changed" do
        before do
          current_form.submission_email = "i-have-changed@example.com"
          current_form.name = "a different name"
        end

        it "calls the SubmissionEmailMailer" do
          expect(SubmissionEmailMailer).to receive(:alert_email_change).with(
            live_email: live_form_document.content["submission_email"],
            form_name: live_form_document.content["name"],
            creator_name: current_user.name,
            creator_email: current_user.email,
          ).and_call_original

          make_form_live_service.make_live
        end
      end
    end
  end

  describe "#page_title" do
    before do
      make_form_live_service.make_live
    end

    it "returns a page title" do
      expect(make_form_live_service.page_title).to eq I18n.t("page_titles.your_form_is_live")
    end

    context "when changes to live form are being made live" do
      let(:current_form) { create :form, :live_with_draft }

      it "returns a different page title" do
        expect(make_form_live_service.page_title).to eq I18n.t("page_titles.your_changes_are_live")
      end
    end
  end

  describe "#confirmation_page_body" do
    before do
      make_form_live_service.make_live
    end

    it "returns a confirmation page body" do
      expect(make_form_live_service.confirmation_page_body).to eq I18n.t("make_live.confirmation.body_html")
    end

    context "when changes to live form are being made live" do
      let(:current_form) { create :form, :live_with_draft }

      it "returns different confirmation page body" do
        expect(make_form_live_service.confirmation_page_body).to eq I18n.t("make_changes_live.confirmation.body_html")
      end
    end
  end
end
