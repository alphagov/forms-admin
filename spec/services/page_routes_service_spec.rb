require "rails_helper"

RSpec.describe PageRoutesService do
  subject(:page_routes_service) do
    described_class.new(form:, pages:, page:)
  end

  let(:form) do
    build(:form)
  end

  include_context "with pages with routing"

  describe "#routes" do
    subject(:routes) { page_routes_service.routes }

    context "when page has no routes" do
      let(:page) { page_with_no_routes }

      it { is_expected.to eq [] }
    end

    context "when page is at the end of a route" do
      let(:page) { end_of_a_secondary_skip }

      it { is_expected.to eq [] }
    end

    context "when page has a skip route" do
      let(:page) { page_with_skip_route }

      it { is_expected.to eq page.routing_conditions }
    end

    context "when page has a skip and secondary skip" do
      let(:page) { page_with_skip_and_secondary_skip }

      it { is_expected.to eq(page.routing_conditions + start_of_a_secondary_skip.routing_conditions) }
    end
  end
end
