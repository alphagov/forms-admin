require "rails_helper"

RSpec.describe ReportsController, type: :request do
  let(:question_text) { "Question text" }
  let(:forms) { create_list(:form, 4, :live) }

  before do
    group = create :group
    forms.each { |form| group.group_forms.create!(form:) }
  end

  shared_examples "unauthorized user is forbidden" do
    context "when the user is a standard user" do
      before do
        login_as_standard_user

        get path
      end

      it "returns http code 403" do
        expect(response).to have_http_status(:forbidden)
      end

      it "renders the forbidden view" do
        expect(response).to render_template("errors/forbidden")
      end
    end

    context "when the user is an organisation admin" do
      before do
        login_as_organisation_admin_user

        get path
      end

      it "returns http code 403" do
        expect(response).to have_http_status(:forbidden)
      end

      it "renders the forbidden view" do
        expect(response).to render_template("errors/forbidden")
      end
    end
  end

  describe "#index" do
    let(:path) { reports_path }

    include_examples "unauthorized user is forbidden"

    context "when the user is a super admin" do
      before do
        login_as_super_admin_user

        get path
      end

      it "returns http code 200" do
        expect(response).to have_http_status(:ok)
      end

      it "renders the features index view" do
        expect(response).to render_template("reports/index")
      end

      it "includes the heading text" do
        expect(response.body).to include "Reports"
      end
    end
  end

  describe "#features" do
    let(:path) { report_features_path(tag: :live) }

    include_examples "unauthorized user is forbidden"

    context "when the user is a super admin" do
      before do
        login_as_super_admin_user

        get path
      end

      it "returns http code 200" do
        expect(response).to have_http_status(:ok)
      end

      it "renders the features report view" do
        expect(response).to render_template("reports/features")
      end

      it "includes the report data" do
        node = Capybara.string(response.body)
        expect(node).to have_xpath "//dl/div[1]/dt", text: "Total live forms"
        expect(node).to have_xpath "//dl/div[1]/dd", text: "4"
      end
    end
  end

  describe "#questions_with_answer_type" do
    let(:path) { report_questions_with_answer_type_path(tag: :live, answer_type: "email") }

    include_examples "unauthorized user is forbidden"

    context "when the user is a super admin" do
      let(:form) do
        create(:form, :live, pages: [
          create(:page, answer_type: "email"),
        ])
      end
      let(:forms) { [form] }

      before do
        login_as_super_admin_user

        get path
      end

      it "returns http code 200" do
        expect(response).to have_http_status(:ok)
      end

      it "renders the features report view" do
        expect(response).to render_template("reports/questions_with_answer_type")
      end

      it "includes the report data" do
        node = Capybara.string(response.body)
        expect(node).to have_xpath "//thead/tr/th[3]", text: "Question text"
        expect(node).to have_xpath "//tbody/tr[1]/td[3]", text: form.pages.first.question_text
      end
    end
  end

  describe "#questions_with_add_another_answer" do
    let(:path) { report_questions_with_add_another_answer_path(tag: :live) }
    let(:form) do
      create(:form, :live, pages: [
        create(:page, is_repeatable: true),
      ])
    end
    let(:forms) { [form] }

    include_examples "unauthorized user is forbidden"

    context "when the user is a super admin" do
      before do
        login_as_super_admin_user

        get path
      end

      it "returns http code 200" do
        expect(response).to have_http_status(:ok)
      end

      it "renders the features report view" do
        expect(response).to render_template("reports/feature_report")
      end

      it "includes the report data" do
        node = Capybara.string(response.body)
        expect(node).to have_xpath "//thead/tr/th[3]", text: "Question text"
        expect(node).to have_xpath "//tbody/tr/td[3]", text: form.pages.first.question_text
      end
    end
  end

  describe "#forms_with_routes" do
    let(:path) { report_forms_with_routes_path(tag: :live) }
    let(:form) do
      form = create(:form, :live, :ready_for_routing)
      create(:condition, routing_page_id: form.pages.first.id, check_page_id: form.pages.first.id, answer_value: "Option 1", goto_page_id: form.pages.second.id)
      form.live_form_document.update!(content: form.reload.as_form_document(live_at: form.updated_at))
      form
    end
    let(:forms) { [form] }

    include_examples "unauthorized user is forbidden"

    context "when the user is a super admin" do
      before do
        login_as_super_admin_user

        get path
      end

      it "returns http code 200" do
        expect(response).to have_http_status(:ok)
      end

      it "renders the features report view" do
        expect(response).to render_template("reports/feature_report")
      end

      it "includes the report data" do
        node = Capybara.string(response.body)
        expect(node).to have_xpath "//thead/tr/th[3]", text: "Number of routes"
        expect(node).to have_xpath "//tbody/tr[1]/td[3]", text: "1"
      end
    end
  end

  describe "#forms_with_branch_routes" do
    let(:path) { report_forms_with_branch_routes_path(tag: :live) }
    let(:form) do
      form = create(:form, :live, :ready_for_routing)
      create(:condition, routing_page_id: form.pages.first.id, check_page_id: form.pages.first.id, answer_value: "Option 1", goto_page_id: form.pages.third.id)
      create(:condition, routing_page_id: form.pages.second.id, check_page_id: form.pages.first.id, goto_page_id: form.pages.fourth.id)
      form.live_form_document.update!(content: form.reload.as_form_document(live_at: form.updated_at))
      form
    end
    let(:forms) { [form] }

    include_examples "unauthorized user is forbidden"

    context "when the user is a super admin" do
      before do
        login_as_super_admin_user

        get path
      end

      it "returns http code 200" do
        expect(response).to have_http_status(:ok)
      end

      it "renders the features report view" do
        expect(response).to render_template("reports/feature_report")
      end

      it "includes the report data" do
        node = Capybara.string(response.body)
        expect(node).to have_xpath "//thead/tr/th[3]", text: "Number of routes"
        expect(node).to have_xpath "//tbody/tr/td[3]", text: "2"
        expect(node).to have_xpath "//thead/tr/th[4]", text: "Number of branch routes"
        expect(node).to have_xpath "//tbody/tr/td[4]", text: "1"
      end
    end
  end

  describe "#forms_with_payments" do
    let(:path) { report_forms_with_payments_path(tag: :live) }
    let(:form) { create(:form, :live, payment_url: "https://www.gov.uk/payments/organisation/service") }
    let(:forms) { [form] }

    include_examples "unauthorized user is forbidden"

    context "when the user is a super admin" do
      before do
        login_as_super_admin_user

        get path
      end

      it "returns http code 200" do
        expect(response).to have_http_status(:ok)
      end

      it "renders the features report view" do
        expect(response).to render_template("reports/feature_report")
      end

      it "includes the report data" do
        node = Capybara.string(response.body)
        expect(node).to have_xpath "//thead/tr/th[1]", text: "Form name"
        expect(node).to have_xpath "//tbody/tr[1]/td[1]", text: form.name
      end
    end
  end

  describe "#forms_with_csv_submission_enabled" do
    let(:path) { report_forms_with_csv_submission_enabled_path(tag: :live) }
    let(:form) { create(:form, :live, submission_type: "email_with_csv") }
    let(:forms) { [form] }

    include_examples "unauthorized user is forbidden"

    context "when the user is a super admin" do
      before do
        login_as_super_admin_user

        get path
      end

      it "returns http code 200" do
        expect(response).to have_http_status(:ok)
      end

      it "renders the features report view" do
        expect(response).to render_template("reports/feature_report")
      end

      it "includes the report data" do
        node = Capybara.string(response.body)
        expect(node).to have_xpath "//thead/tr/th[1]", text: "Form name"
        expect(node).to have_xpath "//tbody/tr[1]/td[1]", text: form.name
      end
    end
  end

  describe "#users" do
    let(:path) { report_users_path }

    include_examples "unauthorized user is forbidden"

    context "when the user is a super admin" do
      before do
        login_as_super_admin_user

        get path
      end

      it "returns http code 200" do
        expect(response).to have_http_status(:ok)
      end

      it "renders the users report view" do
        expect(response).to render_template("reports/users")
      end
    end
  end

  describe "#add_another_answer" do
    let(:path) { report_add_another_answer_path }
    let(:report_data) do
      OpenStruct.new(
        count: 3,
        forms: [OpenStruct.new(form_id: 3, name: "form name", state: "Draft", repeatable_pages: [OpenStruct.new(page_id: 5, question_text:)])],
      )
    end

    before do
      add_another_answer_usage_service = Reports::AddAnotherAnswerUsageService.new
      allow(add_another_answer_usage_service).to receive(:add_another_answer_forms).and_return(report_data)
      allow(Reports::AddAnotherAnswerUsageService).to receive(:new).and_return(add_another_answer_usage_service)
    end

    include_examples "unauthorized user is forbidden"

    context "when the user is a super admin" do
      before do
        login_as_super_admin_user

        get path
      end

      it "returns http code 200" do
        expect(response).to have_http_status(:ok)
      end

      it "renders the features report view" do
        expect(response).to render_template("reports/add_another_answer")
      end

      it "includes the report data" do
        expect(response.body).to include "All forms with add another answer"
        expect(response.body).to include question_text
      end
    end
  end

  describe "#last_signed_in_at" do
    let!(:users) do
      [
        create(:user, provider: :auth0, last_signed_in_at: (1.year + 2.months).ago),
        create(:user, provider: :auth0, last_signed_in_at: nil),
        create(:user, provider: :gds, last_signed_in_at: nil),
      ]
    end

    before do
      login_as_super_admin_user

      get report_last_signed_in_at_path
    end

    it "returns http code 200" do
      expect(response).to have_http_status(:ok)
    end

    it "renders the last_signed_in_at report view" do
      expect(response).to render_template("reports/last_signed_in_at")
    end

    it "includes the report data" do
      expect(response.body).to include "When users last signed in"
      expect(response.body).to include users.first.email
      expect(response.body).to include users.second.email
      expect(response.body).to include users.third.email
    end
  end

  describe "#selection_questions_summary" do
    let(:summary) do
      OpenStruct.new(
        autocomplete: OpenStruct.new(
          form_count: 234,
          question_count: 432,
          optional_question_count: 20,
        ),
        radios: OpenStruct.new(
          form_count: 2,
          question_count: 2,
          optional_question_count: 1,
        ),
        checkboxes: OpenStruct.new(
          form_count: 1,
          question_count: 1,
          optional_question_count: 1,
        ),
      )
    end

    before do
      selection_question_service = Reports::SelectionQuestionService.new
      allow(selection_question_service).to receive(:live_form_statistics).and_return(summary)
      allow(Reports::SelectionQuestionService).to receive(:new).and_return(selection_question_service)

      login_as_super_admin_user
      get report_selection_questions_summary_path
    end

    it "returns http code 200" do
      expect(response).to have_http_status(:ok)
    end

    it "renders the selection questions summary report view" do
      expect(response).to render_template("reports/selection_questions/summary")
    end
  end

  describe "selection question reports" do
    let(:data) do
      OpenStruct.new(
        questions: [
          OpenStruct.new(
            form_id: 1,
            form_name: "A form",
            question_text: "A question",
            is_optional: true,
            selection_options_count: 33,
          ),
        ],
        count: 1,
      )
    end

    describe "#selection_questions_with_autocomplete" do
      before do
        selection_question_service = Reports::SelectionQuestionService.new
        allow(selection_question_service).to receive(:live_form_pages_with_autocomplete).and_return(data)
        allow(Reports::SelectionQuestionService).to receive(:new).and_return(selection_question_service)

        login_as_super_admin_user
        get report_selection_questions_with_autocomplete_path
      end

      it "returns http code 200" do
        expect(response).to have_http_status(:ok)
      end

      it "renders the autocomplete questions report view" do
        expect(response).to render_template("reports/selection_questions/autocomplete")
      end

      it "includes the report data" do
        expect(response.body).to include "A form"
        expect(response.body).to include "A question"
      end
    end

    describe "#selection_questions_with_radios" do
      before do
        selection_question_service = Reports::SelectionQuestionService.new
        allow(selection_question_service).to receive(:live_form_pages_with_radios).and_return(data)
        allow(Reports::SelectionQuestionService).to receive(:new).and_return(selection_question_service)

        login_as_super_admin_user
        get report_selection_questions_with_radios_path
      end

      it "returns http code 200" do
        expect(response).to have_http_status(:ok)
      end

      it "renders the autocomplete questions report view" do
        expect(response).to render_template("reports/selection_questions/radios")
      end

      it "includes the report data" do
        expect(response.body).to include "A form"
        expect(response.body).to include "A question"
      end
    end

    describe "#selection_questions_with_checkboxes" do
      before do
        selection_question_service = Reports::SelectionQuestionService.new
        allow(selection_question_service).to receive(:live_form_pages_with_checkboxes).and_return(data)
        allow(Reports::SelectionQuestionService).to receive(:new).and_return(selection_question_service)

        login_as_super_admin_user
        get report_selection_questions_with_checkboxes_path
      end

      it "returns http code 200" do
        expect(response).to have_http_status(:ok)
      end

      it "renders the autocomplete questions report view" do
        expect(response).to render_template("reports/selection_questions/checkboxes")
      end

      it "includes the report data" do
        expect(response.body).to include "A form"
        expect(response.body).to include "A question"
      end
    end
  end

  describe "csv downloads" do
    shared_examples_for "csv response" do
      it "returns http code 200" do
        expect(response).to have_http_status(:ok)
      end

      it "has content-type text/csv" do
        expect(response.headers["content-type"]).to eq "text/csv; charset=iso-8859-1"
      end
    end

    describe "#live_forms_csv" do
      before do
        login_as_super_admin_user

        travel_to Time.utc(2025, 5, 15, 15, 31, 57)

        get report_live_forms_csv_path
      end

      it_behaves_like "csv response"

      it "responds with an attachment content-disposition header" do
        expect(response.headers["content-disposition"]).to match("attachment; filename=live_forms_report-2025-05-15 15:31:57 UTC.csv")
      end

      it "has expected response body" do
        csv = CSV.parse(response.body, headers: true)
        expect(csv.headers).to eq Reports::FormsCsvReportService::FORM_CSV_HEADERS
        expect(csv.length).to eq 4
      end
    end

    describe "#forms_with_routes as csv" do
      let(:form) do
        form = create(:form, :live, :ready_for_routing)
        create(:condition, routing_page_id: form.pages.first.id, check_page_id: form.pages.first.id, answer_value: "Option 1", goto_page_id: form.pages.second.id)
        form.live_form_document.update!(content: form.reload.as_form_document(live_at: form.updated_at))
        form
      end
      let(:forms) { [form, *create_list(:form, 2, :live)] }

      before do
        login_as_super_admin_user

        travel_to Time.utc(2025, 5, 15, 15, 31, 57)

        get report_forms_with_routes_path(tag: :live, format: :csv)
      end

      it_behaves_like "csv response"

      it "responds with an attachment content-disposition header" do
        expect(response.headers["content-disposition"]).to match("attachment; filename=live_forms_with_routes_report-2025-05-15 15:31:57 UTC.csv")
      end

      it "has expected response body" do
        csv = CSV.parse(response.body, headers: true)
        expect(csv.headers).to eq Reports::FormsCsvReportService::FORM_CSV_HEADERS
        expect(csv.length).to eq 1
        expect(csv.by_col["Form name"]).to eq [
          form.name,
        ]
      end
    end

    describe "#forms_with_payments as csv" do
      let(:form) { create(:form, :live, payment_url: "https://www.gov.uk/payments/organisation/service") }
      let(:forms) { [form, *create_list(:form, 2, :live)] }

      before do
        login_as_super_admin_user

        travel_to Time.utc(2025, 5, 15, 15, 31, 57)

        get report_forms_with_payments_path(tag: :live, format: :csv)
      end

      it_behaves_like "csv response"

      it "responds with an attachment content-disposition header" do
        expect(response.headers["content-disposition"]).to match("attachment; filename=live_forms_with_payments_report-2025-05-15 15:31:57 UTC.csv")
      end

      it "has expected response body" do
        csv = CSV.parse(response.body, headers: true)
        expect(csv.headers).to eq Reports::FormsCsvReportService::FORM_CSV_HEADERS
        expect(csv.length).to eq 1
        expect(csv.by_col["Form name"]).to eq [
          form.name,
        ]
      end
    end

    describe "#forms_with_csv_submission_enabled as csv" do
      let(:form) { create(:form, :live, submission_type: "email_with_csv") }
      let(:forms) { [form, *create_list(:form, 2, :live)] }

      before do
        login_as_super_admin_user

        travel_to Time.utc(2025, 5, 15, 15, 31, 57)

        get report_forms_with_csv_submission_enabled_path(tag: :live, format: :csv)
      end

      it_behaves_like "csv response"

      it "responds with an attachment content-disposition header" do
        expect(response.headers["content-disposition"]).to match("attachment; filename=live_forms_with_csv_submission_enabled_report-2025-05-15 15:31:57 UTC.csv")
      end

      it "has expected response body" do
        csv = CSV.parse(response.body, headers: true)
        expect(csv.headers).to eq Reports::FormsCsvReportService::FORM_CSV_HEADERS
        expect(csv.length).to eq 1
        expect(csv.by_col["Form name"]).to eq [
          form.name,
        ]
      end
    end

    describe "#live_questions_csv" do
      before do
        login_as_super_admin_user

        travel_to Time.utc(2025, 5, 15, 15, 31, 57)

        get report_live_questions_csv_path
      end

      it_behaves_like "csv response"

      it "responds with an attachment content-disposition header" do
        expect(response.headers["content-disposition"]).to match("attachment; filename=live_questions_report-2025-05-15 15:31:57 UTC.csv")
      end

      it "has expected response body" do
        csv = CSV.parse(response.body, headers: true)
        expect(csv.headers).to eq Reports::QuestionsCsvReportService::QUESTIONS_CSV_HEADERS
        expect(csv.length).to eq 20
      end
    end

    describe "#questions_with_answer_type as csv" do
      let(:form) do
        create(:form, :live, pages: [
          create(:page, answer_type: "text"),
        ])
      end
      let(:forms) { [form, *create_list(:form, 2, :live)] }

      before do
        login_as_super_admin_user

        travel_to Time.utc(2025, 5, 15, 15, 31, 57)

        get report_questions_with_answer_type_path(tag: :live, answer_type: "text", format: :csv)
      end

      it_behaves_like "csv response"

      it "responds with an attachment content-disposition header" do
        expect(response.headers["content-disposition"]).to match("attachment; filename=live_questions_report_text_answer_type-2025-05-15 15:31:57 UTC.csv")
      end

      it "has expected response body" do
        csv = CSV.parse(response.body, headers: true)
        expect(csv.headers).to eq Reports::QuestionsCsvReportService::QUESTIONS_CSV_HEADERS
        expect(csv.length).to eq 1
      end
    end

    describe "#questions_with_add_another_answer as csv" do
      let(:form) do
        create(:form, :live, pages: [
          create(:page, is_repeatable: true),
        ])
      end
      let(:forms) { [form, *create_list(:form, 2, :live)] }

      before do
        login_as_super_admin_user

        travel_to Time.utc(2025, 5, 15, 15, 31, 57)

        get report_questions_with_add_another_answer_path(tag: :live, format: :csv)
      end

      it_behaves_like "csv response"

      it "responds with an attachment content-disposition header" do
        expect(response.headers["content-disposition"]).to match("attachment; filename=live_questions_with_add_another_answer_report-2025-05-15 15:31:57 UTC.csv")
      end

      it "has expected response body" do
        csv = CSV.parse(response.body, headers: true)
        expect(csv.headers).to eq Reports::QuestionsCsvReportService::QUESTIONS_CSV_HEADERS
        expect(csv.length).to eq 1
      end
    end
  end
end
