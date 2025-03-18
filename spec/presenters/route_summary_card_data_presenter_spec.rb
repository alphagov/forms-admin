require "rails_helper"

describe RouteSummaryCardDataPresenter do
  include Capybara::RSpecMatchers

  subject(:service) { described_class.new(form:, page:) }

  include_context "with pages with routing"

  let(:form) { build :form, id: 99, pages: }
  let(:page) { page_with_skip_route }

  let(:routes) do
    PageRoutesService.new(form:, pages:, page:).routes
  end

  before do
    allow(form).to receive(:group).and_return(build(:group))
  end

  describe "#summary_card_data" do
    context "with conditional routes" do
      it "returns an array of route cards" do
        result = service.summary_card_data
        expect(result.length).to eq(1) # 1 conditional route

        # conditional route
        expect(result[0][:card][:title]).to eq("Route 1")
        expect(result[0][:card][:actions].first).to have_link("Edit", href: "/forms/99/pages/10/conditions/3")
        expect(result[0][:rows][0][:value][:text]).to eq("Skip")
        expect(result[0][:rows][1][:value][:text]).to eq("12. Question")
      end

      context "when the goto_page does not exist" do
        before do
          page.routing_conditions.first.tap do |condition|
            condition.goto_page_id = 999
          end
        end

        it "uses placeholder text instead of question text" do
          result = service.summary_card_data
          expect(result[0][:rows][1][:value][:text]).to eq(I18n.t("page_route_card.goto_page_invalid"))
        end
      end
    end

    context "with skip to end condition" do
      before do
        page.routing_conditions.first.tap do |condition|
          condition.goto_page_id = nil
          condition.skip_to_end = true
        end
      end

      it 'shows "Check your answers" as destination' do
        result = service.summary_card_data
        expect(result[0][:rows][1][:value][:text]).to eq("Check your answers before submitting")
      end
    end

    context "with conditional routes and secondary skip routes" do
      let(:page) { page_with_skip_and_secondary_skip }

      it "shows the destination of the secondary skip route" do
        result = service.summary_card_data
        expect(result[1][:rows][0][:value][:text]).to eq("3. Question in branch 1")
        expect(result[1][:rows][1][:value][:text]).to eq("4. Question at the end of branch 1 (start of a secondary skip)")
        expect(result[1][:rows][2][:value][:text]).to eq("8. Question after a branch route (end of a secondary skip)")
      end

      context "when branch routing is not enabled", feature_branch_routing: false do
        it "has no actions" do
          result = service.summary_card_data
          expect(result[1][:card][:actions]).to be_empty
        end
      end

      context "with branch_routing enabled", :feature_branch_routing do
        it "shows the edit secondary skip link" do
          result = service.summary_card_data
          expect(result[1][:card][:actions].first).to have_link("Edit", href: "/forms/99/pages/2/routes/any-other-answer/questions-to-skip")
        end

        it "shows the delete secondary skip link" do
          result = service.summary_card_data
          expect(result[1][:card][:actions].second).to have_link("Delete", href: "/forms/99/pages/2/routes/any-other-answer/questions-to-skip/delete")
        end
      end
    end

    context "with no conditional routes" do
      let(:page) { page_with_no_routes }

      it "returns an empty array" do
        result = service.summary_card_data
        expect(result).to eq []
      end
    end
  end
end
