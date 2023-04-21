require "rails_helper"

RSpec.describe Pages::ConditionsForm, type: :model do
  let(:conditions_form) { described_class.new(form:, page:) }
  let(:form) { build :form, :ready_for_routing, id: 1 }
  let(:pages) { form.pages }
  let(:page) { pages.second }

  let(:post_headers) do
    {
      "X-API-Token" => Settings.forms_api.auth_key,
      "Content-Type" => "application/json",
    }
  end

  # before do
  #   form
  # end

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

  describe "#routing_answer_options" do
    it "returns a list of answers for the given page" do
      result = conditions_form.routing_answer_options.map(&:name)
      expect(result).to eq([nil, "Option 1", "Option 2"])
    end

    context "when selection setting includes 'none of the above'" do
      let(:page) { build :page, :with_selections_settings, is_optional: "true" }

      it "adds extra 'None of above' options to the end" do
        result = conditions_form.routing_answer_options.map(&:name)
        expect(result).to eq([nil, "Option 1", "Option 2", I18n.t("page_options_service.selection_type.none_of_the_above")])
      end
    end
  end

  describe "#goto_page_options" do
    it "returns a list of answers for the given page" do
      result = described_class.new(form:, page: pages.first).goto_page_options
      expect(result).to eq([OpenStruct.new(id: nil, question_text: nil), form.pages.map { |p| OpenStruct.new(id: p.id, question_text: p.question_text) }].flatten)
    end
  end
end
