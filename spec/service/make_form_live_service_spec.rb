require "rails_helper"

describe MakeFormLiveService do
  let(:make_form_live_service) { described_class.call(current_form:, current_user:) }
  let(:current_form) { build :form, :ready_for_live, id: 1 }
  let(:live_form) { current_form }
  let(:current_user) { build :user }

  describe "#make_live" do
    before do
      allow(current_form).to receive(:make_live!).and_return(true)
    end

    it "calls make_live! on the current form" do
      expect(current_form).to receive(:make_live!)
      make_form_live_service.make_live
    end

    it "does not call the SubmissionEmailMailer" do
      expect(SubmissionEmailMailer).not_to receive(:alert_email_change)
      make_form_live_service.make_live
    end

    context "when draft form has live version" do
      let(:live_form) { build :form, :live }
      let(:current_form) do
        live_form.clone
      end

      before do
        ActiveResource::HttpMock.respond_to do |mock|
          mock.get "/api/v1/forms/#{live_form.id}/live", headers, live_form.to_json, 200
        end
      end

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
            live_email: live_form.submission_email,
            form_name: live_form.name,
            creator_name: current_user.name,
            creator_email: current_user.email,
          ).and_call_original

          make_form_live_service.make_live
        end
      end
    end
  end

  describe "#page_title" do
    it "returns a page title" do
      expect(make_form_live_service.page_title).to eq I18n.t("page_titles.your_form_is_live")
    end

    context "when changes to live form are being made live" do
      let(:live_form) { build :form, :live }
      let(:current_form) do
        live_form.clone
      end

      before do
        ActiveResource::HttpMock.respond_to do |mock|
          mock.get "/api/v1/forms/#{live_form.id}/live", headers, live_form.to_json, 200
        end
      end

      it "returns a different page title" do
        expect(make_form_live_service.page_title).to eq I18n.t("page_titles.your_changes_are_live")
      end
    end
  end
end
