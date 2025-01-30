require "rails_helper"

RSpec.describe Pages::RoutingPageInput, type: :model do
  let(:routing_page_input) { described_class.new({ routing_page_id: }, branch_routing_enabled:) }
  let(:form) { build :form, :ready_for_routing, id: 1 }
  let(:pages) { form.pages }
  let(:routing_page_id) { pages.first.id }
  let(:branch_routing_enabled) { false }

  describe "validations" do
    it "is invalid if routing_page_id is nil" do
      error_message = I18n.t("activemodel.errors.models.pages/routing_page_input.attributes.routing_page_id.branch_routing_disabled_blank")
      routing_page_input.routing_page_id = nil
      expect(routing_page_input).to be_invalid
      expect(routing_page_input.errors.full_messages_for(:routing_page_id)).to include("Routing page #{error_message}")
    end

    context "when branch_routing_enabled is true" do
      let(:branch_routing_enabled) { true }

      it "is invalid if routing_page_id is nil" do
        error_message = I18n.t("activemodel.errors.models.pages/routing_page_input.attributes.routing_page_id.blank")
        routing_page_input.routing_page_id = nil
        expect(routing_page_input).to be_invalid
        expect(routing_page_input.errors.full_messages_for(:routing_page_id)).to include("Routing page #{error_message}")
      end
    end
  end
end
