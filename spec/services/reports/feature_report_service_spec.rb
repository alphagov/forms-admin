require "rails_helper"

RSpec.describe Reports::FeatureReportService do
  let(:forms) do
    [
      form_with_all_answer_types,
      form_with_a_few_answer_types,
      branch_route_form,
      basic_route_form,
    ]
  end
  let(:form_documents) { forms.map { |form| form.live_form_document.as_json } }
  let(:group) { create(:group) }

  let(:form_with_all_answer_types) do
    create(:form, :live, :with_support, submission_type: "email", submission_format: %w[csv], payment_url: "https://www.gov.uk/payments/organisation/service", pages: [
      create(:page, :with_address_settings, is_repeatable: true),
      create(:page, :with_date_settings),
      create(:page, answer_type: "email"),
      create(:page, :with_full_name_settings),
      create(:page, answer_type: "national_insurance_number"),
      create(:page, answer_type: "number"),
      create(:page, answer_type: "phone_number"),
      create(:page, :with_selection_settings, is_optional: true),
      create(:page, :with_single_line_text_settings, is_repeatable: true),
    ])
  end
  let(:form_with_a_few_answer_types) do
    create(:form, :live, submission_type: "email", submission_format: %w[csv json], pages: [
      create(:page, answer_type: "email"),
      *create_list(:page, 3, answer_type: "name"),
    ])
  end
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

  before do
    forms.each do |form|
      GroupForm.create!(form: form, group: group)
    end
  end

  describe "#report" do
    it "returns the feature report" do
      report = described_class.new(form_documents).report
      expect(report).to eq({
        total_forms: 4,
        forms_with_payment: 1,
        forms_with_routing: 2,
        forms_with_branch_routing: 1,
        forms_with_add_another_answer: 1,
        forms_with_csv_submission_email_attachments: 2,
        forms_with_json_submission_email_attachments: 1,
        forms_with_answer_type: {
          "address" => 1,
          "date" => 1,
          "email" => 2,
          "name" => 2,
          "national_insurance_number" => 1,
          "number" => 1,
          "phone_number" => 1,
          "selection" => 3,
          "text" => 1,
        },
        steps_with_answer_type: {
          "address" => 1,
          "date" => 1,
          "email" => 2,
          "name" => 4,
          "national_insurance_number" => 1,
          "number" => 1,
          "phone_number" => 1,
          "selection" => 11,
          "text" => 1,
        },
        forms_with_exit_pages: 1,
      })
    end
  end

  describe "#questions" do
    it "returns all questions in all forms given" do
      questions = described_class.new(form_documents).questions
      expect(questions.length).to eq 23
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
      expect(questions.length).to eq 2
      expect(questions).to match [
        a_hash_including(
          "form" => a_hash_including(
            "form_id" => form_with_all_answer_types.id,
            "content" => a_hash_including(
              "name" => form_with_all_answer_types.name,
            ),
          ),
          "data" => a_hash_including(
            "question_text" => form_with_all_answer_types.pages[2].question_text,
          ),
        ),
        a_hash_including(
          "form" => a_hash_including(
            "form_id" => form_with_a_few_answer_types.id,
            "content" => a_hash_including(
              "name" => form_with_a_few_answer_types.name,
            ),
          ),
          "data" => a_hash_including(
            "question_text" => form_with_a_few_answer_types.pages[0].question_text,
          ),
        ),
      ]
    end

    it "returns questions with the given answer type" do
      questions = described_class.new(form_documents).questions_with_answer_type("name")
      expect(questions.length).to eq 4
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
      expect(questions).to contain_exactly(
        a_hash_including(
          "form" => a_hash_including(
            "form_id" => form_with_all_answer_types.id,
            "content" => a_hash_including(
              "name" => form_with_all_answer_types.name,
            ),
          ),
          "data" => a_hash_including(
            "question_text" => form_with_all_answer_types.pages[0].question_text,
          ),
        ),
        a_hash_including(
          "form" => a_hash_including(
            "form_id" => form_with_all_answer_types.id,
            "content" => a_hash_including(
              "name" => form_with_all_answer_types.name,
            ),
          ),
          "data" => a_hash_including(
            "question_text" => form_with_all_answer_types.pages[8].question_text,
          ),
        ),
      )
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
  end

  describe "#forms_with_branch_routes" do
    it "returns details needed to render report" do
      forms = described_class.new(form_documents).forms_with_branch_routes
      expect(forms).to match [
        a_hash_including(
          "form_id" => branch_route_form.id,
          "content" => a_hash_including(
            "name" => branch_route_form.name,
          ),
          "metadata" => {
            "number_of_routes" => 3,
            "number_of_branch_routes" => 1,
          },
        ),
      ]
    end

    it "returns forms with branch routes" do
      forms = described_class.new(form_documents).forms_with_branch_routes
      expect(forms).to match [
        a_hash_including(
          "form_id" => branch_route_form.id,
          "content" => a_hash_including(
            "name" => branch_route_form.name,
          ),
        ),
      ]
    end

    it "includes counts of routes" do
      forms = described_class.new(form_documents).forms_with_branch_routes
      expect(forms).to all include(
        "metadata" => a_hash_including(
          "number_of_routes" => an_instance_of(Integer),
          "number_of_branch_routes" => an_instance_of(Integer),
        ),
      )
    end
  end

  describe "#forms_with_payments" do
    it "returns live forms with payments" do
      forms = described_class.new(form_documents).forms_with_payments
      expect(forms).to match [
        a_hash_including(
          "form_id" => form_with_all_answer_types.id,
          "content" => a_hash_including(
            "name" => form_with_all_answer_types.name,
          ),
        ),
      ]
    end
  end

  describe "#forms_with_exit_pages" do
    it "returns live forms with payments" do
      forms = described_class.new(form_documents).forms_with_exit_pages
      expect(forms).to match [
        a_hash_including(
          "form_id" => branch_route_form.id,
          "content" => a_hash_including(
            "name",
          ),
        ),
      ]
    end
  end

  describe "#forms_with_csv_submission_email_attachments" do
    it "returns live forms with csv enabled" do
      forms = described_class.new(form_documents).forms_with_csv_submission_email_attachments
      expect(forms).to match [
        a_hash_including(
          "form_id" => form_with_all_answer_types.id,
          "content" => a_hash_including(
            "name" => form_with_all_answer_types.name,
          ),
        ),
        a_hash_including(
          "form_id" => form_with_a_few_answer_types.id,
          "content" => a_hash_including(
            "name" => form_with_a_few_answer_types.name,
          ),
        ),
      ]
    end
  end

  describe "#forms_with_json_submission_email_attachments" do
    it "returns live forms with json enabled" do
      forms = described_class.new(form_documents).forms_with_json_submission_email_attachments
      expect(forms).to match [
        a_hash_including(
          "form_id" => form_with_a_few_answer_types.id,
          "content" => a_hash_including(
            "name" => form_with_a_few_answer_types.name,
          ),
        ),
      ]
    end
  end
end
