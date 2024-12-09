require "rails_helper"

RSpec.describe "pages/delete" do
  before do
    assign(:back_url, edit_question_path(form_id: 1, page_id: 1))
    assign(:confirm_deletion_legend, "Are you sure you want to delete this page?")
    assign(:delete_confirmation_input, Forms::DeleteConfirmationInput.new)
    assign(:item_name, "What’s your name?")
    assign(:url, destroy_page_path(form_id: 1, page_id: 1))

    render
  end

  it "has a page title" do
    expect(view.content_for(:title)).to include "Are you sure you want to delete this page?"
  end

  it "has a heading" do
    expect(rendered).to have_css "h1", text: "Are you sure you want to delete this page?"
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
end
