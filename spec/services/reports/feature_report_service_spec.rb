require "rails_helper"

RSpec.describe Reports::FeatureReportService do
  let(:form_documents) { JSON.parse(file_fixture("form_documents_response.json").read) }
  let(:group) { create(:group) }

  before do
    GroupForm.create!(form_id: 1, group:)
    GroupForm.create!(form_id: 2, group:)
    GroupForm.create!(form_id: 3, group:)
    GroupForm.create!(form_id: 4, group:)
  end

  describe "Constraint" do
    it "returns true if given the name of a defined report in slug format" do
      expect(described_class::Constraint.matches?(OpenStruct.new(params: { report: "forms-with-routes" }))).to be true
      expect(described_class::Constraint.matches?(OpenStruct.new(params: { report: "questions-with-add-another-answer" }))).to be true
    end

    it "returns false if names does not match a defined report" do
      expect(described_class.matches_report?(OpenStruct.new(params: { report: "report" }))).to be false
      expect(described_class.matches_report?(OpenStruct.new(params: { report: "inspect" }))).to be false
      expect(described_class.matches_report?(OpenStruct.new(params: { report: "display" }))).to be false
    end
  end

  describe ".matches_report?" do
    it "returns true if given the name of a defined report" do
      expect(described_class.matches_report?(:forms_with_routes)).to be true
      expect(described_class.matches_report?(:questions_with_add_another_answer)).to be true
    end

    it "returns false if names does not match a defined report" do
      expect(described_class.matches_report?(:report)).to be false
      expect(described_class.matches_report?(:inspect)).to be false
      expect(described_class.matches_report?(:display)).to be false
    end
  end

  describe "#report" do
    it "returns the feature report" do
      report = described_class.new(form_documents).report
      expect(report).to eq({
        total_forms: 4,
        forms_with_payment: 1,
        forms_with_routing: 2,
        forms_with_add_another_answer: 1,
        forms_with_csv_submission_enabled: 1,
        forms_with_answer_type: {
          "address" => 1,
          "date" => 1,
          "email" => 2,
          "name" => 2,
          "national_insurance_number" => 1,
          "number" => 1,
          "phone_number" => 1,
          "selection" => 3,
          "text" => 3,
        },
        steps_with_answer_type: {
          "address" => 1,
          "date" => 1,
          "email" => 2,
          "name" => 2,
          "national_insurance_number" => 1,
          "number" => 1,
          "phone_number" => 1,
          "selection" => 3,
          "text" => 5,
        },
      })
    end

    context "with the name of a feature report" do
      it "returns that report" do
        report = []
        feature_report_service = described_class.new(form_documents)
        allow(feature_report_service).to receive(:forms_with_routes).and_return report

        expect(feature_report_service.report(:forms_with_routes)).to be report

        expect(feature_report_service).to have_received(:forms_with_routes)
      end
    end

    context "with the name of a method that is not a feature report" do
      it "raises an error" do
        feature_report_service = described_class.new(form_documents)
        allow(feature_report_service).to receive(:display)

        expect { feature_report_service.report(:display) }.to raise_error(/not a defined report/)

        expect(feature_report_service).not_to have_received(:display)
      end
    end
  end

  describe "#questions" do
    it "returns all questions in all forms given" do
      questions = described_class.new(form_documents).questions
      expect(questions.length).to eq 17
    end

    it "returns details needed to render report" do
      questions = described_class.new(form_documents).questions
      expect(questions).to all match(
        a_hash_including(
          "form" => a_hash_including(
            "form_id" => an_instance_of(Integer),
            "content" => a_hash_including(
              "name" => a_kind_of(String),
            ),
          ),
          "data" => a_hash_including(
            "question_text" => a_kind_of(String),
          ),
        ),
      )
    end

    it "includes a reference to the form document" do
      questions = described_class.new(form_documents).questions_with_answer_type("text")
      expect(questions).to all include(
        "form" => a_hash_including(
          "form_id",
          "content" => a_hash_including(
            "name",
          ),
        ),
      )
    end
  end

  describe "#questions_with_answer_type" do
    it "returns details needed to render report" do
      questions = described_class.new(form_documents).questions_with_answer_type("email")
      expect(questions).to match [
        a_hash_including(
          "form" => a_hash_including(
            "form_id" => 1,
            "content" => a_hash_including(
              "name" => "All question types form",
            ),
          ),
          "data" => a_hash_including(
            "question_text" => "Email address",
          ),
        ),
        a_hash_including(
          "form" => a_hash_including(
            "form_id" => 3,
            "content" => a_hash_including(
              "name" => "Branch route form",
            ),
          ),
          "data" => a_hash_including(
            "question_text" => "What’s your email address?",
          ),
        ),
      ]
    end

    it "returns questions with the given answer type" do
      questions = described_class.new(form_documents).questions_with_answer_type("name")
      expect(questions.length).to eq 2
      expect(questions).to all match(
        a_hash_including(
          "data" => a_hash_including(
            "answer_type" => "name",
          ),
        ),
      )
    end

    it "includes a reference to the form document" do
      questions = described_class.new(form_documents).questions_with_answer_type("text")
      expect(questions).to all include(
        "form" => a_hash_including(
          "form_id",
          "content" => a_hash_including(
            "name",
          ),
        ),
      )
    end
  end

  describe "#questions_with_add_another_answer" do
    it "returns details needed to render report" do
      questions = described_class.new(form_documents).questions_with_add_another_answer
      expect(questions).to match [
        a_hash_including(
          "form" => a_hash_including(
            "form_id" => 1,
            "content" => a_hash_including(
              "name" => "All question types form",
            ),
            "group" => a_hash_including(
              "organisation" => a_hash_including(
                "name" => group.organisation.name,
              ),
            ),
          ),
          "data" => a_hash_including(
            "question_text" => "Single line of text",
          ),
        ),
        a_hash_including(
          "form" => a_hash_including(
            "form_id" => 1,
            "content" => a_hash_including(
              "name" => "All question types form",
            ),
            "group" => a_hash_including(
              "organisation" => a_hash_including(
                "name" => group.organisation.name,
              ),
            ),
          ),
          "data" => a_hash_including(
            "question_text" => "Number",
          ),
        ),
      ]
    end

    it "returns questions with add another answer" do
      questions = described_class.new(form_documents).questions_with_add_another_answer
      expect(questions).to all match(
        a_hash_including(
          "data" => a_hash_including(
            "is_repeatable" => true,
          ),
        ),
      )
    end

    it "includes a reference to the form document" do
      questions = described_class.new(form_documents).questions_with_answer_type("text")
      expect(questions).to all include(
        "form" => a_hash_including(
          "form_id",
          "content" => a_hash_including(
            "name",
          ),
        ),
      )
    end

    it "includes a reference to the organisation record" do
      questions = described_class.new(form_documents).questions_with_answer_type("text")
      expect(questions).to all include(
        "form" => a_hash_including(
          "group" => a_hash_including(
            "organisation" => a_hash_including(
              "name",
            ),
          ),
        ),
      )
    end
  end

  describe "#forms_with_routes" do
    it "returns details needed to render report" do
      forms = described_class.new(form_documents).forms_with_routes
      expect(forms).to match [
        a_hash_including(
          "form_id" => 3,
          "content" => a_hash_including(
            "name" => "Branch route form",
          ),
          "group" => a_hash_including(
            "organisation" => a_hash_including(
              "name" => group.organisation.name,
            ),
          ),
          "metadata" => {
            "number_of_routes" => 2,
          },
        ),
        a_hash_including(
          "form_id" => 4,
          "content" => a_hash_including(
            "name" => "Skip route form",
          ),
          "group" => a_hash_including(
            "organisation" => a_hash_including(
              "name" => group.organisation.name,
            ),
          ),
          "metadata" => {
            "number_of_routes" => 1,
          },
        ),
      ]
    end

    it "returns forms with routes" do
      forms = described_class.new(form_documents).forms_with_routes
      expect(forms).to match [
        a_hash_including(
          "form_id" => 3,
          "content" => a_hash_including(
            "name" => "Branch route form",
          ),
        ),
        a_hash_including(
          "form_id" => 4,
          "content" => a_hash_including(
            "name" => "Skip route form",
          ),
        ),
      ]
    end

    it "includes counts of routes" do
      forms = described_class.new(form_documents).forms_with_routes
      expect(forms).to all include(
        "metadata" => a_hash_including(
          "number_of_routes" => an_instance_of(Integer),
        ),
      )
    end

    it "includes a reference to the organisation record" do
      forms = described_class.new(form_documents).forms_with_routes
      expect(forms).to all include(
        "group" => a_hash_including(
          "organisation" => a_hash_including(
            "name",
          ),
        ),
      )
    end
  end

  describe "#forms_with_payments" do
    it "returns live forms with payments" do
      forms = described_class.new(form_documents).forms_with_payments
      expect(forms).to match [
        a_hash_including(
          "form_id" => 1,
          "content" => a_hash_including(
            "name" => "All question types form",
          ),
        ),
      ]
    end

    it "includes a reference to the organisation record" do
      forms = described_class.new(form_documents).forms_with_routes
      expect(forms).to all include(
        "group" => a_hash_including(
          "organisation" => a_hash_including(
            "name",
          ),
        ),
      )
    end
  end

  describe "#forms_with_csv_submission_enabled" do
    it "returns live forms with csv enabled" do
      forms = described_class.new(form_documents).forms_with_csv_submission_enabled
      expect(forms).to match [
        a_hash_including(
          "form_id" => 1,
          "content" => a_hash_including(
            "name" => "All question types form",
          ),
        ),
      ]
    end

    it "includes a reference to the organisation record" do
      forms = described_class.new(form_documents).forms_with_routes
      expect(forms).to all include(
        "group" => a_hash_including(
          "organisation" => a_hash_including(
            "name",
          ),
        ),
      )
    end
  end
end
