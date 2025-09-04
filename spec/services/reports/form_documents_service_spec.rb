require "rails_helper"

RSpec.describe Reports::FormDocumentsService do
  let(:forms) do
    [
      form_with_no_routes,
      branch_route_form,
      basic_route_form,
      form_with_2_branch_routes,
    ]
  end
  let(:form_documents) { forms.map(&:live_form_document) }

  let(:form_with_no_routes) { create(:form, :live) }
  let(:branch_route_form) do
    form = create(:form, :live, :ready_for_routing)
    create(:condition, :with_exit_page, routing_page_id: form.pages[0].id, check_page_id: form.pages[0].id, answer_value: "Option 1")
    create(:condition, routing_page_id: form.pages[1].id, check_page_id: form.pages[1].id, answer_value: "Option 1", goto_page_id: form.pages[3].id)
    create(:condition, routing_page_id: form.pages[2].id, check_page_id: form.pages[1].id, goto_page_id: form.pages[4].id)
    form.live_form_document.update!(content: form.reload.as_form_document(live_at: form.updated_at))
    form
  end

  let(:basic_route_form) do
    form = create(:form, :live, :ready_for_routing)
    create(:condition, routing_page_id: form.pages.first.id, check_page_id: form.pages.first.id, answer_value: "Option 1", skip_to_end: true)
    form.live_form_document.update!(content: form.reload.as_form_document(live_at: form.updated_at))
    form
  end

  let(:form_with_2_branch_routes) do
    form = create(:form, :live, :ready_for_routing, pages_count: 10)
    create(:condition, routing_page_id: form.pages[1].id, check_page_id: form.pages[1].id, answer_value: "Option 1", goto_page_id: form.pages[3].id)
    create(:condition, routing_page_id: form.pages[2].id, check_page_id: form.pages[1].id, answer_value: "Option 2", goto_page_id: form.pages[4].id)
    create(:condition, routing_page_id: form.pages[6].id, check_page_id: form.pages[6].id, answer_value: "Option 1", goto_page_id: form.pages[8].id)
    create(:condition, routing_page_id: form.pages[7].id, check_page_id: form.pages[6].id, answer_value: "Option 2", goto_page_id: form.pages[9].id)
    form.live_form_document.update!(content: form.reload.as_form_document(live_at: form.updated_at))
    form
  end

  describe ".form_documents" do
    let(:form_documents_url) { "#{Settings.forms_api.base_url}/api/v2/form-documents".freeze }
    let(:tag) { "live" }

    before do
      allow(Settings.reports).to receive(:forms_api_forms_per_request_page).and_return 4

      stub_request(:get, form_documents_url)
        .with(query: { page: "1", per_page: "4", tag: })
        .to_return(body: form_documents.to_json, headers: response_headers(12, 0, 4))
      stub_request(:get, form_documents_url)
        .with(query: { page: "2", per_page: "4", tag: })
        .to_return(body: form_documents.to_json, headers: response_headers(12, 4, 4))
      stub_request(:get, form_documents_url)
        .with(query: { page: "3", per_page: "4", tag: })
        .to_return(body: form_documents.to_json, headers: response_headers(12, 8, 4))
    end

    context "with draft tag" do
      let(:tag) { "draft" }

      it "makes request to forms-api for each page of results" do
        form_documents = described_class.form_documents(tag:).to_a
        expect(form_documents.size).to eq(12)
        assert_requested(:get, form_documents_url, query: { page: "1", per_page: "4", tag: "draft" }, headers:, times: 1)
        assert_requested(:get, form_documents_url, query: { page: "2", per_page: "4", tag: "draft" }, headers:, times: 1)
        assert_requested(:get, form_documents_url, query: { page: "3", per_page: "4", tag: "draft" }, headers:, times: 1)
      end

      it "returns form documents" do
        form_document = described_class.form_documents(tag:).first
        expect(form_document).to be_a(Hash)
        expect(form_document).to have_key("form_id")
      end
    end

    context "with live tag" do
      let(:tag) { :live }

      it "makes request to forms-api for each page of results" do
        form_documents = described_class.form_documents(tag:).to_a
        expect(form_documents.size).to eq(12)
        assert_requested(:get, form_documents_url, query: { page: "1", per_page: "4", tag: "live" }, headers:, times: 1)
        assert_requested(:get, form_documents_url, query: { page: "2", per_page: "4", tag: "live" }, headers:, times: 1)
        assert_requested(:get, form_documents_url, query: { page: "3", per_page: "4", tag: "live" }, headers:, times: 1)
      end

      it "returns form documents" do
        form_document = described_class.form_documents(tag:).first
        expect(form_document).to be_a(Hash)
        expect(form_document).to have_key("form_id")
      end

      context "when there are forms from internal organisations" do
        let(:organisation) { create :organisation, internal: false, slug: "hm-revenue-customs" }
        let(:internal_organisation) { create :organisation, internal: true, slug: "internal-org" }
        let(:group) { create :group, organisation: }
        let(:internal_group) { create :group, organisation: internal_organisation }

        before do
          group.group_forms.create!(form: forms[0])
          group.group_forms.create!(form: forms[1])
          group.group_forms.create!(form: forms[2])
          internal_group.group_forms.create!(form: forms[3])
        end

        it "does not include these forms in the live_form_documents output" do
          form_documents = described_class.live_form_documents.to_a
          expect(form_documents.size).to eq(9)

          form_documents_with_internal_id = form_documents.filter { it["id"] == forms[3].id }
          expect(form_documents_with_internal_id).to be_empty
        end
      end
    end

    context "when forms-api responds with a non-success status code" do
      before do
        stub_request(:get, form_documents_url)
          .with(query: { page: "1", per_page: "4", tag: "live" })
          .to_return(body: "There was an error", status: 400)
      end

      it "raises a StandardError" do
        expect { described_class.form_documents(tag: "live").first }.to raise_error(
          StandardError, "Forms API responded with a non-success HTTP code when retrieving form documents: status 400"
        )
      end
    end

    context "when there are forms from internal organisations" do
      let(:organisation) { create :organisation, internal: false, slug: "hm-revenue-customs" }
      let(:internal_organisation) { create :organisation, internal: true, slug: "internal-org" }
      let(:group) { create :group, organisation: }
      let(:internal_group) { create :group, organisation: internal_organisation }
      let(:tag) { "draft" }

      before do
        group.group_forms.create!(form: forms[0])
        group.group_forms.create!(form: forms[1])
        group.group_forms.create!(form: forms[2])
        internal_group.group_forms.create!(form: forms[3])
      end

      it "does not include these forms in the draft_form_documents output" do
        form_documents = described_class.form_documents(tag:).to_a
        expect(form_documents.size).to eq(9)

        form_documents_with_internal_id = form_documents.filter { it["id"] == forms[3].id }
        expect(form_documents_with_internal_id).to be_empty
      end
    end

    def response_headers(total, offset, limit)
      {
        "pagination-total" => total.to_s,
        "pagination-offset" => offset.to_s,
        "pagination-limit" => limit.to_s,
      }
    end
  end

  describe ".has_secondary_skip_routes?" do
    subject(:count_secondary_skip_routes) do
      described_class.has_secondary_skip_routes?(form_document)
    end

    context "when form has one step with one secondary skip condition" do
      let(:form_document) { branch_route_form.live_form_document }

      it { is_expected.to be true }
    end

    context "when form has two steps each with one secondary skip condition" do
      let(:form_document) { form_with_2_branch_routes.live_form_document }

      it { is_expected.to be true }
    end

    context "when form has no secondary skip conditions" do
      let(:form_document) { basic_route_form.live_form_document }

      it { is_expected.to be false }
    end
  end

  describe ".count_secondary_skip_routes" do
    subject(:count_secondary_skip_routes) do
      described_class.count_secondary_skip_routes(form_document)
    end

    context "when form has one step with one secondary skip condition" do
      let(:form_document) { branch_route_form.live_form_document }

      it { is_expected.to eq 1 }
    end

    context "when form has two steps each with one secondary skip condition" do
      let(:form_document) { form_with_2_branch_routes.live_form_document }

      it { is_expected.to eq 2 }
    end

    context "when form has no secondary skip conditions" do
      let(:form_document) { basic_route_form.live_form_document }

      it { is_expected.to eq 0 }
    end
  end

  describe ".step_has_secondary_skip_route?" do
    context "when step is check page for secondary skip condition" do
      let(:form_document) { branch_route_form.live_form_document }
      let(:step) { form_document["content"]["steps"][1] }

      it "returns true" do
        expect(described_class.step_has_secondary_skip_route?(form_document, step)).to be true
      end
    end

    context "when step is not check page for secondary skip condition" do
      let(:form_document) { branch_route_form.live_form_document }
      let(:step) { form_document["content"]["steps"][3] }

      it "returns false" do
        expect(described_class.step_has_secondary_skip_route?(form_document, step)).to be false
      end
    end

    context "when form has no secondary skip conditions" do
      let(:form_document) { basic_route_form.live_form_document }
      let(:step) { form_document["content"]["steps"][0] }

      it "returns false" do
        expect(described_class.step_has_secondary_skip_route?(form_document, step)).to be false
      end
    end
  end

  describe ".has_exit_pages?" do
    subject(:has_exit_pages?) do
      described_class.has_exit_pages?(form_document)
    end

    context "when form has one step with one exit page" do
      let(:form_document) { branch_route_form.live_form_document }

      it { is_expected.to be true }
    end

    context "when form has no exit pages" do
      let(:form_document) { basic_route_form.live_form_document }

      it { is_expected.to be false }
    end
  end
end
