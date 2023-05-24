require "rails_helper"

RSpec.describe Pages::RoutingPageForm, type: :model do
  let(:routing_page_form) { described_class.new(routing_page_id:) }
  let(:form) { build :form, :ready_for_routing, id: 1 }
  let(:pages) { form.pages }
  let(:routing_page_id) { pages.first.id }

  let(:delete_headers) do
    {
      "X-API-Token" => Settings.forms_api.auth_key,
      "Accept" => "application/json",
    }
  end

  describe "validations" do
    it "is invalid if routing_page_id is nil" do
      error_message = I18n.t("activemodel.errors.models.pages/routing_page_form.attributes.routing_page_id.blank")
      routing_page_form.routing_page_id = nil
      expect(routing_page_form).to be_invalid
      expect(routing_page_form.errors.full_messages_for(:routing_page_id)).to include("Routing page #{error_message}")
    end
  end
end
