require "rails_helper"

RSpec.describe "pages/delete" do
  let(:delete_confirmation_input) { Forms::DeleteConfirmationInput.new }
  let(:current_form) { create :form }
  let(:page) { create :page, form: current_form }

  before do
    assign(:back_url, edit_question_path(form_id: current_form.id, page_id: page.id))
    assign(:delete_confirmation_input, delete_confirmation_input)
    assign(:item_name, "What’s your name?")
    assign(:page, page)
    assign(:url, destroy_page_path(form_id: current_form.id, page_id: page.id))

    render locals: { current_form: }
  end

  it "has a page title" do
    expect(view.content_for(:title)).to include "Are you sure you want to delete this question?"
  end

  it "has a heading" do
    expect(rendered).to have_css "h1", text: "Are you sure you want to delete this question?"
  end

  it "has a heading caption with the question text" do
    expect(rendered).to have_css ".govuk-caption-l", text: "What’s your name?"
  end

  it "has a back link to the edit question page" do
    expect(view.content_for(:back_link)).to have_link "Back", href: "/forms/#{current_form.id}/pages/#{page.id}/edit/question"
  end

  it "has a delete confirmation input to confirm deletion of the page" do
    expect(rendered).to render_template "input_objects/_delete_confirmation_input"
  end

  describe "delete confirmation input" do
    it "posts to the destroy action" do
      expect(rendered).to have_element "form", action: "/forms/#{current_form.id}/pages/#{page.id}/delete", method: "post"
    end

    it "does not have a hint" do
      expect(rendered).not_to have_css ".govuk-hint"
    end
  end

  context "when page to delete is not associated with any routes" do
    it "does not render a notification banner" do
      expect(rendered).not_to have_css ".govuk-notification-banner"
    end
  end

  context "when page to delete is the start of one or more routes" do
    before do
      assign(:routing, :start_of_route)
      assign(:route_page, page)

      render locals: { current_form: }
    end

    it "renders a notification banner" do
      expect(rendered).to have_css ".govuk-notification-banner"
    end

    describe "notification banner" do
      subject(:banner) { rendered.html.at_css(".govuk-notification-banner") }

      it { is_expected.to have_text "Important" }
      it { is_expected.to have_css "h3.govuk-notification-banner__heading", text: "Question #{page.position} is the start of a route", count: 1 }
      it { is_expected.to have_css "p.govuk-body", text: "If you delete this question, its routes will also be deleted." }
      it { is_expected.to have_link "View question #{page.position}’s routes", class: "govuk-notification-banner__link", href: show_routes_path(current_form.id, page.id) }
    end

    context "but there was an error in the user's input" do
      let(:delete_confirmation_input) do
        delete_confirmation_input = Forms::DeleteConfirmationInput.new(confirm: "")
        delete_confirmation_input.validate
        delete_confirmation_input
      end

      it "does not render the notification banner" do
        expect(rendered).not_to have_css ".govuk-notification-banner"
      end
    end
  end

  describe "when page to delete is at the end of one or more routes" do
    let(:routing_page) { build :page, id: 1, position: 2 }
    let(:page) { build :page, id: 2, position: 7 }

    before do
      assign(:routing, :end_of_route)
      assign(:route_page, routing_page)

      render locals: { current_form: }
    end

    it "renders a notification banner" do
      expect(rendered).to have_css ".govuk-notification-banner"
    end

    describe "notification banner" do
      subject(:banner) { rendered.html.at_css(".govuk-notification-banner") }

      it { is_expected.to have_text "Important" }
      it { is_expected.to have_css "h3.govuk-notification-banner__heading", text: "Question #{page.position} is at the end of a route", count: 1 }
      it { is_expected.to have_link "Question #{routing_page.position}’s route", class: "govuk-notification-banner__link", href: show_routes_path(current_form.id, routing_page.id) }
      it { is_expected.to have_css "p.govuk-body", text: "Question #{routing_page.position}’s route goes to this question. If you delete this question, question #{routing_page.position}’s routes will also be deleted.", normalize_ws: true }
    end

    context "but there was an error in the user's input" do
      let(:delete_confirmation_input) do
        delete_confirmation_input = Forms::DeleteConfirmationInput.new(confirm: "")
        delete_confirmation_input.validate
        delete_confirmation_input
      end

      it "does not render the notification banner" do
        expect(rendered).not_to have_css ".govuk-notification-banner"
      end
    end
  end

  describe "when page to delete is start of a secondary skip route" do
    let(:check_page) { build(:page, id: 2, form_id: 1, position: 1) }
    let(:page) { build(:page, id: 1, form_id: 1, position: 2) }

    before do
      assign(:routing, :start_of_secondary_skip_route)
      assign(:route_page, check_page)

      render locals: { current_form: }
    end

    it "renders a notification banner" do
      expect(rendered).to have_css ".govuk-notification-banner"
    end

    describe "notification banner" do
      subject(:banner) { rendered.html.at_css(".govuk-notification-banner") }

      it { is_expected.to have_text "Important" }
      it { is_expected.to have_css "h3.govuk-notification-banner__heading", text: "Question #{page.position} is the start of a route", count: 1 }
      it { is_expected.to have_link "Question #{check_page.position}’s route", class: "govuk-notification-banner__link", href: show_routes_path(current_form.id, check_page.id) }
      it { is_expected.to have_css "p.govuk-body", text: "If you delete this question, the route from it will also be deleted." }
    end

    context "but there was an error in the user's input" do
      let(:delete_confirmation_input) do
        delete_confirmation_input = Forms::DeleteConfirmationInput.new(confirm: "")
        delete_confirmation_input.validate
        delete_confirmation_input
      end

      it "does not render the notification banner" do
        expect(rendered).not_to have_css ".govuk-notification-banner"
      end
    end
  end

  describe "when page to delete is at the end of a secondary skip route" do
    let(:check_page) { build(:page, id: 1, form_id: 1, position: 3) }
    let(:page) { build(:page, id: 9, form_id: 1, position: 12) }

    before do
      assign(:routing, :end_of_secondary_skip_route)
      assign(:route_page, check_page)

      render locals: { current_form: }
    end

    it "renders a notification banner" do
      expect(rendered).to have_css ".govuk-notification-banner"
    end

    describe "notification banner" do
      subject(:banner) { rendered.html.at_css(".govuk-notification-banner") }

      it { is_expected.to have_text "Important" }
      it { is_expected.to have_css "h3.govuk-notification-banner__heading", text: "Question #{page.position} is at the end of a route", count: 1 }
      it { is_expected.to have_link "Question #{check_page.position}’s route", class: "govuk-notification-banner__link", href: show_routes_path(current_form.id, check_page.id) }
      it { is_expected.to have_css "p.govuk-body", text: "Question #{check_page.position}’s route goes to this question. If you delete this question, the route to it will also be deleted.", normalize_ws: true }
    end

    context "but there was an error in the user's input" do
      let(:delete_confirmation_input) do
        delete_confirmation_input = Forms::DeleteConfirmationInput.new(confirm: "")
        delete_confirmation_input.validate
        delete_confirmation_input
      end

      it "does not render the notification banner" do
        expect(rendered).not_to have_css ".govuk-notification-banner"
      end
    end
  end
end
