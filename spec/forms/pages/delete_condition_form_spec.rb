require "rails_helper"

RSpec.describe Pages::DeleteConditionForm, type: :model do
  let(:delete_condition_form) { described_class.new(form:, page:, record: condition) }
  let(:form) { build :form, :ready_for_routing, id: 1 }
  let(:pages) { form.pages }
  let(:page) { pages.second }
  let(:condition) { nil }

  let(:delete_headers) do
    {
      "X-API-Token" => Settings.forms_api.auth_key,
      "Accept" => "application/json",
    }
  end

  describe "validations" do
    it "is invalid if confirm_deletion is nil" do
      error_message = I18n.t("activemodel.errors.models.pages/delete_condition_form.attributes.confirm_deletion.blank")
      delete_condition_form.confirm_deletion = nil
      expect(delete_condition_form).to be_invalid
      expect(delete_condition_form.errors.full_messages_for(:confirm_deletion)).to include("Confirm deletion #{error_message}")
    end
  end

  describe "#delete" do
    context "when validation pass" do
      let(:condition) { Condition.new id: 2, form_id: 1, page_id: 2, routing_page_id: 1, check_page_id: 1, answer_value: "Wales", goto_page_id: 3 }

      it "destroys a condition" do
        ActiveResource::HttpMock.respond_to do |mock|
          mock.delete "/api/v1/forms/1/pages/2/conditions/", delete_headers, { success: true }.to_json, 200
        end

        delete_condition_form.confirm_deletion = "true"

        expect(delete_condition_form.delete).to be_truthy
      end
    end

    context "when validations fail" do
      it "returns false" do
        invalid_delete_condition_form = described_class.new
        expect(invalid_delete_condition_form.delete).to be false
      end
    end
  end

  describe "#goto_page_options" do
    it "returns a list of answers for the given page" do
      result = described_class.new(form:, page: pages.first).goto_page_options
      expect(result).to eq([OpenStruct.new(id: nil, question_text: I18n.t("helpers.label.pages_conditions_form.default_goto_page_id")), form.pages.map { |p| OpenStruct.new(id: p.id, question_text: p.question_text) }].flatten)
    end
  end
end
