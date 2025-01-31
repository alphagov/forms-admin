require "rails_helper"

RSpec.describe PageConditionsService do
  subject(:page_conditions_service) do
    described_class.new(form:, pages:, page:)
  end

  let(:form) do
    build(:form)
  end

  include_context "with pages with routing"

  describe "#check_conditions" do
    subject(:check_conditions) { page_conditions_service.check_conditions }

    context "when page has no routes" do
      let(:page) { page_with_no_routes }

      it { is_expected.to eq [] }
    end

    context "when page has no check conditions" do
      let(:page) { end_of_a_secondary_skip }

      it { is_expected.to eq [] }
    end

    context "when page has check conditions" do
      let(:page) { page_with_skip_and_secondary_skip }

      it { is_expected.to eq(page_with_skip_and_secondary_skip.routing_conditions + start_of_a_secondary_skip.routing_conditions) }
    end
  end

  describe "#routing_conditions" do
    subject(:routing_conditions) { page_conditions_service.routing_conditions }

    context "when page has no routes" do
      let(:page) { page_with_no_routes }

      it { is_expected.to eq [] }
    end

    context "when page has no routing conditions" do
      let(:page) { end_of_a_secondary_skip }

      it { is_expected.to eq [] }
    end

    context "when page has routing conditions" do
      let(:page) { page_with_skip_and_secondary_skip }

      it { is_expected.to eq page.routing_conditions }
    end
  end
end
