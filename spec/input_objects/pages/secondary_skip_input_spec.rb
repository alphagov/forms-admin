require "rails_helper"

RSpec.describe Pages::SecondarySkipInput, type: :model do
  let(:secondary_skip_input) { described_class.new(form:, page:) }

  let(:form) { create :form, :ready_for_routing }
  let(:pages) { form.pages }
  let(:is_optional) { false }
  let(:page) { pages.second }
  let(:condition) { nil }

  before do
    allow(FormRepository).to receive_messages(pages:)
  end

  describe "validations" do
    it "is valid given valid params" do
      secondary_skip_input.routing_page_id = form.pages.first.id.to_s
      secondary_skip_input.goto_page_id = form.pages[3].id.to_s
      expect(secondary_skip_input).to be_valid
    end

    it "is invalid if goto_page_id is nil" do
      error_message = I18n.t("activemodel.errors.models.pages/secondary_skip_input.attributes.goto_page_id.blank")
      secondary_skip_input.goto_page_id = nil
      expect(secondary_skip_input).to be_invalid
      expect(secondary_skip_input.errors.full_messages_for(:goto_page_id)).to include("Goto page #{error_message}")
    end

    it "is invalid if routing_page_id is nil" do
      error_message = I18n.t("activemodel.errors.models.pages/secondary_skip_input.attributes.routing_page_id.blank")
      secondary_skip_input.routing_page_id = nil
      expect(secondary_skip_input).to be_invalid
      expect(secondary_skip_input.errors.full_messages_for(:routing_page_id)).to include("Routing page #{error_message}")
    end

    it "is invalid if routing_page is after the goto_page" do
      error_message = I18n.t("activemodel.errors.models.pages/secondary_skip_input.attributes.goto_page_id.routing_page_after")
      secondary_skip_input.routing_page_id = form.pages[2].id.to_s
      secondary_skip_input.goto_page_id = form.pages.first.id.to_s
      expect(secondary_skip_input).to be_invalid
      expect(secondary_skip_input.errors.full_messages_for(:goto_page_id)).to include("Goto page #{error_message}")
    end

    it "is invalid if routing_page and goto_page are already consecutive" do
      error_message = I18n.t("activemodel.errors.models.pages/secondary_skip_input.attributes.goto_page_id.already_consecutive")
      secondary_skip_input.routing_page_id = form.pages.first.id.to_s
      secondary_skip_input.goto_page_id = form.pages.second.id.to_s
      expect(secondary_skip_input).to be_invalid
      expect(secondary_skip_input.errors.full_messages_for(:goto_page_id)).to include("Goto page #{error_message}")
    end

    it "is invalid if routing_page and goto_page are the same" do
      error_message = I18n.t("activemodel.errors.models.pages/secondary_skip_input.attributes.goto_page_id.equal")
      secondary_skip_input.routing_page_id = form.pages.first.id.to_s
      secondary_skip_input.goto_page_id = form.pages.first.id.to_s
      expect(secondary_skip_input).to be_invalid
      expect(secondary_skip_input.errors.full_messages_for(:goto_page_id)).to include("Goto page #{error_message}")
    end
  end
end
