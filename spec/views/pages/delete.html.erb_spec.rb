require "rails_helper"

RSpec.describe "pages/delete" do
  let(:page) { build :page, id: 1 }

  before do
    assign(:back_url, edit_question_path(form_id: 1, page_id: page.id))
    assign(:delete_confirmation_input, Forms::DeleteConfirmationInput.new)
    assign(:item_name, "What’s your name?")
    assign(:page, page)
    assign(:url, destroy_page_path(form_id: 1, page_id: page.id))

    current_form = build :form, id: 1

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
    expect(view.content_for(:back_link)).to have_link "Back", href: "/forms/1/pages/1/edit/question"
  end

  it "has a delete confirmation input to confirm deletion of the page" do
    expect(rendered).to render_template "input_objects/forms/_delete_confirmation_input"
  end

  describe "delete confirmation input" do
    it "posts to the destroy action" do
      expect(rendered).to have_element "form", action: "/forms/1/pages/1/delete", method: "post"
    end

    it "does not have a hint" do
      expect(rendered).not_to have_css ".govuk-hint"
    end
  end

  describe "when page to delete is not associated with any routes" do
    it "does not render a notification banner" do
      expect(rendered).not_to have_css ".govuk-notification-banner"
    end
  end

  describe "when page to delete is the start of one or more routes" do
    let(:page) { build :page, id: 1, form_id: 1, position: 2, routing_conditions: true }

    it "renders a notification banner" do
      expect(rendered).to have_css ".govuk-notification-banner"
    end

    describe "notification banner" do
      subject(:banner) { rendered.html.at_css(".govuk-notification-banner") }

      it { is_expected.to have_text "Important" }
      it { is_expected.to have_css "h3.govuk-notification-banner__heading", text: "Question 2 is the start of a route", count: 1 }
      it { is_expected.to have_css "p.govuk-body", text: "If you delete this question, its routes will also be deleted." }
      it { is_expected.to have_link "View question 2’s routes", class: "govuk-notification-banner__link", href: show_routes_path(1, 1) }
    end
  end
end
