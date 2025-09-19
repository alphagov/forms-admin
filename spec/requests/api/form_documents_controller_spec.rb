require "rails_helper"

RSpec.describe Api::FormDocumentsController, type: :request do
  let(:headers) { { "ACCEPT": "application/json" } }

  describe "GET /show" do
    context "when the form exists" do
      context "when the tag is draft" do
        let(:draft_form_name) { "Draft form" }
        let(:form) { create(:form, :live_with_draft, pages_count: 2) }

        before do
          # change the form object so we can be sure we're returning the draft form document
          form.name = draft_form_name
          form.save!

          get "/api/v2/forms/#{form.id}/draft", headers:
        end

        it "returns http success" do
          expect(response).to have_http_status(:success)
        end

        it "returns the draft form document" do
          expect(response.parsed_body).to include({
            form_id: form.id.to_s,
            name: draft_form_name,
          })
        end

        it "includes the form's steps in the response" do
          expect(response.parsed_body["steps"].count).to eq(2)
        end
      end

      context "when the tag is live" do
        let(:live_form_name) { "Live form" }
        let(:form) { create(:form, :live, name: live_form_name) }

        before do
          # change the form object so we can be sure we're returning the live form document
          form.name = "Draft form"
          form.save!

          get "/api/v2/forms/#{form.id}/live", headers:
        end

        it "returns http success" do
          expect(response).to have_http_status(:success)
        end

        it "returns the live form document" do
          expect(response.parsed_body).to include({
            form_id: form.id.to_s,
            name: live_form_name,
          })
        end
      end

      context "when the tag is archived" do
        let(:archived_form_name) { "Archived form" }
        let(:form) { create(:form, :archived, name: archived_form_name) }

        before do
          # change the form object so we can be sure we're returning the archived form document
          form.name = "Draft form"
          form.save!

          get "/api/v2/forms/#{form.id}/archived"
        end

        it "returns http success" do
          expect(response).to have_http_status(:success)
        end

        it "returns the archived form document" do
          expect(response.parsed_body).to include({
            form_id: form.id.to_s,
            name: archived_form_name,
          })
        end
      end
    end

    context "when the form doesn't exist" do
      before do
        get "/api/v2/forms/non-existent/draft", headers:
      end

      it "returns http not found" do
        expect(response).to have_http_status(:not_found)
        expect(response.headers["Content-Type"]).to eq("application/json; charset=utf-8")
      end
    end

    context "when a form document with the given tag doesn't exist" do
      let(:form) { create :form }

      before do
        get "/api/v2/forms/#{form.id}/live", headers:
      end

      it "returns http not found" do
        expect(response).to have_http_status(:not_found)
        expect(response.headers["Content-Type"]).to eq("application/json; charset=utf-8")
      end
    end

    context "when given an unsupported tag" do
      let(:form) { create :form }

      before do
        get "/api/v2/forms/#{form.id}/unknown-tag", headers:
      end

      it "returns http not found" do
        expect(response).to have_http_status(:not_found)
        expect(response.headers["Content-Type"]).to eq("application/json; charset=utf-8")
      end
    end
  end

  describe "logging", :capture_logging do
    let(:trace_id) { "Root=1-63441c4a-abcdef012345678912345678" }
    let(:request_id) { "a-request-id" }
    let(:form_id) { "a-form-id" }
    let(:headers) do
      {
        "ACCEPT": "application/json",
        "HTTP_X_AMZN_TRACE_ID": trace_id,
        "X-Request-ID": request_id,
      }
    end

    before do
      get api_v2_form_document_path(form_id:, tag: "live"), headers:
    end

    it "includes the trace ID on log lines" do
      expect(log_line["trace_id"]).to eq(trace_id)
    end

    it "includes the request_id on log lines" do
      expect(log_line["request_id"]).to eq(request_id)
    end

    it "includes the request_host on log lines" do
      expect(log_line["request_host"]).to eq("www.example.com")
    end

    it "includes the form_id on log lines" do
      expect(log_line["form_id"]).to eq(form_id)
    end
  end
end
