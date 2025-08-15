require "rails_helper"

describe MakeFormLiveService do
  let(:make_form_live_service) { described_class.call(current_form:, current_user:) }
  let(:current_form) { build :form, :ready_for_live, id: 1 }
  let(:made_live_form) { build :made_live_form, id: current_form.id, submission_email: current_form.submission_email }
  let(:current_user) { build :user }

  before do
    allow(FormRepository).to receive(:make_live!) do |form|
      form.state = "live"
    end

    allow(FormRepository).to receive_messages(find_live: made_live_form)
  end

  describe "#make_live" do
    it "calls make_live! on the Form Repository with the current form" do
      expect(FormRepository).to receive(:make_live!).with(current_form)
      make_form_live_service.make_live
    end

    it "does not call the SubmissionEmailMailer" do
      expect(SubmissionEmailMailer).not_to receive(:alert_email_change)
      make_form_live_service.make_live
    end

    context "when draft form has live version" do
      let(:current_form) { build :form, :live_with_draft, id: 1 }

      context "when submission email has not been changed" do
        it "does not call the SubmissionEmailMailer" do
          expect(SubmissionEmailMailer).not_to receive(:alert_email_change)

          make_form_live_service.make_live
        end
      end

      context "when submission email has changed" do
        before do
          current_form.submission_email = "i-have-changed@example.com"
        end

        it "calls the SubmissionEmailMailer" do
          expect(SubmissionEmailMailer).to receive(:alert_email_change).with(
            live_email: made_live_form.submission_email,
            form_name: made_live_form.name,
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
      let(:current_form) { build :form, :live_with_draft, id: 1 }

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
      let(:current_form) { build :form, :live_with_draft, id: 1 }

      before do
        allow(FormRepository).to receive(:find_live).and_return(made_live_form)
      end

      it "returns different confirmation page body" do
        expect(make_form_live_service.confirmation_page_body).to eq I18n.t("make_changes_live.confirmation.body_html")
      end
    end
  end
end
