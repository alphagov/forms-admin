require "rails_helper"

RSpec.describe Reports::FeatureReportService do
  let(:form_documents_response_json) { JSON.parse(file_fixture("form_documents_response.json").read) }
  let(:group) { create(:group) }

  before do
    GroupForm.create!(form_id: 1, group:)
    GroupForm.create!(form_id: 2, group:)
    GroupForm.create!(form_id: 3, group:)

    allow(Reports::FormDocumentsService).to receive(:live_form_documents).and_return(form_documents_response_json)
  end

  describe "#report" do
    it "returns the feature report" do
      report = described_class.report
      expect(report).to eq({
        total_live_forms: 3,
        live_forms_with_payment: 1,
        live_forms_with_routing: 1,
        live_forms_with_add_another_answer: 1,
        live_forms_with_csv_submission_enabled: 1,
        live_forms_with_answer_type: {
          "address" => 1,
          "date" => 1,
          "email" => 2,
          "name" => 1,
          "national_insurance_number" => 1,
          "number" => 1,
          "phone_number" => 1,
          "selection" => 2,
          "text" => 3,
        },
        live_steps_with_answer_type: {
          "address" => 1,
          "date" => 1,
          "email" => 2,
          "name" => 1,
          "national_insurance_number" => 1,
          "number" => 1,
          "phone_number" => 1,
          "selection" => 2,
          "text" => 5,
        },
      })
    end
  end

  describe "#questions_with_answer_type" do
    it "returns questions with the given answer type" do
      questions = described_class.questions_with_answer_type("email")
      expect(questions.length).to eq 2
      expect(questions).to include(
        {
          form_name: "All question types form",
          form_id: 1,
          organisation_name: group.organisation.name,
          question_text: "Email address",
        },
      )
      expect(questions).to include({
        form_name: "Branch route form",
        form_id: 3,
        organisation_name: group.organisation.name,
        question_text: "What’s your email address?",
      })
    end
  end

  describe "#live_questions_with_add_another_answer" do
    it "returns questions with add another answer" do
      questions = described_class.live_questions_with_add_another_answer
      expect(questions.length).to eq 2
      expect(questions).to include(
        {
          form_name: "All question types form",
          form_id: 1,
          organisation_name: group.organisation.name,
          question_text: "Single line of text",
        },
      )
      expect(questions).to include({
        form_name: "All question types form",
        form_id: 1,
        organisation_name: group.organisation.name,
        question_text: "Number",
      })
    end
  end

  describe "#live_forms_with_routes" do
    it "returns forms with routes" do
      forms = described_class.live_forms_with_routes
      expect(forms.length).to eq 1
      expect(forms).to include(
        form_name: "Branch route form",
        form_id: 3,
        organisation_name: group.organisation.name,
        number_of_routes: 2,
      )
    end
  end

  describe "#live_forms_with_payments" do
    it "returns live forms with payments" do
      forms = described_class.live_forms_with_payments
      expect(forms.length).to eq 1
      expect(forms).to include(
        form_name: "All question types form",
        form_id: 1,
        organisation_name: group.organisation.name,
      )
    end
  end

  describe "#live_forms_with_csv_submission_enabled" do
    it "returns live forms with csv enabled" do
      forms = described_class.live_forms_with_csv_submission_enabled
      expect(forms.length).to eq 1
      expect(forms).to include(
        form_name: "All question types form",
        form_id: 1,
        organisation_name: group.organisation.name,
      )
    end
  end
end
