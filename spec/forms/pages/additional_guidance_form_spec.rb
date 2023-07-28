require "rails_helper"

RSpec.describe Pages::AdditionalGuidanceForm, type: :model do
  let(:additional_guidance_form) { described_class.new }

  describe "validations" do
    it "is invalid if answer_value is nil" do
      error_message = I18n.t("activemodel.errors.models.pages/additional_guidance_form.attributes.page_heading.blank")
      additional_guidance_form.page_heading = nil
      expect(additional_guidance_form).to be_invalid
      expect(additional_guidance_form.errors.full_messages_for(:page_heading)).to include("Page heading #{error_message}")
    end

    it "is invalid if goto_page_id is nil" do
      error_message = I18n.t("activemodel.errors.models.pages/additional_guidance_form.attributes.additional_guidance_markdown.blank")
      additional_guidance_form.additional_guidance_markdown = nil
      expect(additional_guidance_form).to be_invalid
      expect(additional_guidance_form.errors.full_messages_for(:additional_guidance_markdown)).to include("Additional guidance markdown #{error_message}")
    end
  end
end
