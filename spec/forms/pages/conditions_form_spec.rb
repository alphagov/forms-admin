require "rails_helper"

RSpec.describe Pages::ConditionsForm, type: :model do
  let(:conditions_form) { described_class.new(form:, page:, record: condition) }
  let(:form) { build :form, :ready_for_routing, id: 1 }
  let(:pages) { form.pages }
  let(:page) { pages.second }
  let(:condition) { nil }

  let(:post_headers) do
    {
      "X-API-Token" => Settings.forms_api.auth_key,
      "Content-Type" => "application/json",
    }
  end

  describe "validations" do
    it "is invalid if answer_value is nil" do
      error_message = I18n.t("activemodel.errors.models.pages/conditions_form.attributes.answer_value.blank")
      conditions_form.answer_value = nil
      expect(conditions_form).to be_invalid
      expect(conditions_form.errors.full_messages_for(:answer_value)).to include("Answer value #{error_message}")
    end

    it "is invalid if goto_page_id is nil" do
      error_message = I18n.t("activemodel.errors.models.pages/conditions_form.attributes.goto_page_id.blank")
      conditions_form.goto_page_id = nil
      expect(conditions_form).to be_invalid
      expect(conditions_form.errors.full_messages_for(:goto_page_id)).to include("Goto page #{error_message}")
    end
  end

  describe "#submit" do
    context "when validation pass" do
      before do
        ActiveResource::HttpMock.respond_to do |mock|
          mock.post "/api/v1/forms/1/pages/2/conditions", post_headers, { id: 2 }.to_json, 200
        end

        page.id = 2
        conditions_form.answer_value = "Rabbit"
        conditions_form.goto_page_id = 4
      end

      it "calls assign_skip_to_end" do
        allow(conditions_form).to receive(:assign_skip_to_end)
        conditions_form.submit

        expect(conditions_form).to have_received(:assign_skip_to_end).exactly(1).times
      end

      it "creates a condition" do
        expect(conditions_form.submit).to be_truthy
      end
    end

    context "when validations fail" do
      it "returns false" do
        invalid_conditions_form = described_class.new
        expect(invalid_conditions_form.submit).to be false
      end
    end
  end

  describe "#update_condition" do
    context "when validation pass" do
      let(:condition) { Condition.new id: 3, form_id: 1, page_id: 2, routing_page_id: 1, check_page_id: 1, answer_value: "Wales", goto_page_id: 3 }

      before do
        ActiveResource::HttpMock.respond_to do |mock|
          mock.post "/api/v1/forms/1/pages/2/conditions", post_headers, { success: true }.to_json, 200
          mock.put "/api/v1/forms/1/pages/2/conditions/3", post_headers, { success: true }.to_json, 200
        end

        conditions_form.answer_value = "England"
        conditions_form.goto_page_id = 4
      end

      it "calls assign_skip_to_end" do
        allow(conditions_form).to receive(:assign_skip_to_end)

        conditions_form.update_condition

        expect(conditions_form).to have_received(:assign_skip_to_end).exactly(1).times
      end

      it "updates a condition" do
        expect(conditions_form.update_condition).to be_truthy
      end
    end

    context "when validations fail" do
      it "returns false" do
        invalid_conditions_form = described_class.new
        expect(invalid_conditions_form.update_condition).to be false
      end
    end
  end

  describe "#routing_answer_options" do
    it "returns a list of answers for the given page" do
      result = conditions_form.routing_answer_options
      expect(result).to eq([
        OpenStruct.new(value: nil, label: I18n.t("helpers.label.pages_conditions_form.default_answer_value")),
        OpenStruct.new(value: "Option 1", label: "Option 1"),
        OpenStruct.new(value: "Option 2", label: "Option 2"),
      ])
    end

    context "when selection setting includes 'none of the above'" do
      let(:page) { build :page, :with_selections_settings, is_optional: "true" }

      it "adds extra 'None of above' options to the end" do
        result = conditions_form.routing_answer_options
        expect(result).to eq([
          OpenStruct.new(value: nil, label: I18n.t("helpers.label.pages_conditions_form.default_answer_value")),
          OpenStruct.new(value: "Option 1", label: "Option 1"),
          OpenStruct.new(value: "Option 2", label: "Option 2"),
          OpenStruct.new(value: I18n.t("page_options_service.selection_type.none_of_the_above"),
                         label: I18n.t("page_options_service.selection_type.none_of_the_above")),
        ])
      end
    end
  end

  describe "#goto_page_options" do
    context "when routing from the first form page" do
      it "returns a list of all pages after the first page and includes 'Check your answers'" do
        result = described_class.new(form:, page: pages.first).goto_page_options
        expect(result).to eq([
          OpenStruct.new(id: nil, question_text: I18n.t("helpers.label.pages_conditions_form.default_goto_page_id")),
          form.pages.drop(1).map { |p| OpenStruct.new(id: p.id, question_text: "#{p.position}. #{p.question_text}") },
          OpenStruct.new(id: "check_your_answers", question_text: I18n.t("page_conditions.check_your_answers")),
        ].flatten)
      end
    end

    context "when routing from the third form page" do
      it "returns a list of answers that excludes any pages before the given page and the given page" do
        routing_from_page_position = 3
        result = described_class.new(form:, page: pages[routing_from_page_position - 1]).goto_page_options
        expect(result).to eq([
          OpenStruct.new(id: nil, question_text: I18n.t("helpers.label.pages_conditions_form.default_goto_page_id")),
          form.pages.drop(routing_from_page_position).map { |p| OpenStruct.new(id: p.id, question_text: "#{p.position}. #{p.question_text}") },
          OpenStruct.new(id: "check_your_answers", question_text: I18n.t("page_conditions.check_your_answers")),
        ].flatten)
      end
    end
  end

  describe "#check_errors_from_api" do
    let(:condition) { build :condition, :with_answer_value_missing, id: 3, page_id: 2, routing_page_id: 1, answer_value: "England", check_page_id: 1, goto_page_id: 3 }

    it "is invalid if there are API validation errors" do
      error_message = I18n.t("activemodel.errors.models.pages/conditions_form.attributes.answer_value.answer_value_doesnt_exist")
      conditions_form.check_errors_from_api
      expect(conditions_form.errors.full_messages_for(:answer_value)).to include("Answer value #{error_message}")
    end
  end

  describe "#assign_condition_values" do
    let(:conditions_form) { described_class.new(form:, page:, record: condition, answer_value: condition.answer_value, goto_page_id: condition.goto_page_id, skip_to_end: condition.skip_to_end) }
    let(:condition) { build :condition, id: 3, page_id: 2, routing_page_id: 1, answer_value: "England", check_page_id: 1, goto_page_id:, skip_to_end: }
    let(:goto_page_id) { nil }
    let(:skip_to_end) { false }

    context "when goto_page is nil and skip_to_end is set to true" do
      let(:skip_to_end) { true }

      it "sets goto_page_id to 'check_your_answers'" do
        conditions_form.assign_condition_values
        expect(conditions_form.goto_page_id).to eq "check_your_answers"
      end
    end

    context "when goto_page is nil and skip_to_end is set to false" do
      it "sets goto_page_id to 'check_your_answers'" do
        conditions_form.assign_condition_values
        expect(conditions_form.goto_page_id).to eq nil
      end
    end

    context "when goto_page is not nil" do
      let(:goto_page_id) { 3 }
      let(:skip_to_end) { true }

      it "sets goto_page_id to 'check_your_answers'" do
        conditions_form.assign_condition_values
        expect(conditions_form.goto_page_id).to eq 3
      end
    end
  end

  describe "#assign_skip_to_end" do
    let(:conditions_form) { described_class.new(form:, page:, goto_page_id:, skip_to_end:) }
    let(:goto_page_id) { 3 }
    let(:skip_to_end) { false }

    context "when goto_page is 'check_your_answers" do
      let(:goto_page_id) { "check_your_answers" }

      it "sets goto_page_id to nil and skip_to_end to true" do
        conditions_form.assign_skip_to_end
        expect(conditions_form.goto_page_id).to eq nil
        expect(conditions_form.skip_to_end).to eq true
      end
    end

    context "when goto_page is not 'check_your_answers" do
      let(:goto_page_id) { 3 }
      let(:skip_to_end) { true }

      it "does not change goto_page_id and sets skip_to_end to false" do
        conditions_form.assign_skip_to_end
        expect(conditions_form.goto_page_id).to eq 3
        expect(conditions_form.skip_to_end).to eq false
      end
    end
  end
end
