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
      it "creates a condition" do
        ActiveResource::HttpMock.respond_to do |mock|
          mock.post "/api/v1/forms/1/pages/2/conditions", post_headers, { id: 2 }.to_json, 200
        end

        page.id = 2
        conditions_form.answer_value = "Rabbit"
        conditions_form.goto_page_id = 4

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

  describe "#update" do
    context "when validation pass" do
      let(:condition) { Condition.new id: 3, form_id: 1, page_id: 2, routing_page_id: 1, check_page_id: 1, answer_value: "Wales", goto_page_id: 3 }

      it "updates a condition" do
        ActiveResource::HttpMock.respond_to do |mock|
          mock.post "/api/v1/forms/1/pages/2/conditions", post_headers, { success: true }.to_json, 200
          mock.put "/api/v1/forms/1/pages/2/conditions/3", post_headers, { success: true }.to_json, 200
        end

        conditions_form.answer_value = "England"
        conditions_form.goto_page_id = 4

        expect(conditions_form.update).to be_truthy
      end
    end

    context "when validations fail" do
      it "returns false" do
        invalid_conditions_form = described_class.new
        expect(invalid_conditions_form.update).to be false
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
    it "returns a list of answers for the given page" do
      result = described_class.new(form:, page: pages.first).goto_page_options
      expect(result).to eq([OpenStruct.new(id: nil, question_text: I18n.t("helpers.label.pages_conditions_form.default_goto_page_id")), form.pages.map { |p| OpenStruct.new(id: p.id, question_text: p.question_text) }].flatten)
    end
  end

  describe "#id_for_field" do
    it "returns the correct id for a field" do
      result = described_class.new(form:, page: pages.first).id_for_field(:answer_value)
      expect(result).to eq("condition_answer_value")
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
end
