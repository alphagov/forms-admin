require "rails_helper"

RSpec.describe "forms/delete_confirmation/delete" do
  let(:form) { build :form, id: 1, name: "Test form" }

  before do
    assign(:back_url, form_path(form_id: 1))
    assign(:confirm_deletion_legend, "Are you sure you want to delete this draft?")
    assign(:delete_confirmation_input, Forms::DeleteConfirmationInput.new)
    assign(:item_name, form.name)
    assign(:url, destroy_form_path(form_id: 1))

    render
  end

  it "has a page title" do
    expect(view.content_for(:title)).to include "Are you sure you want to delete this draft?"
  end

  it "has a heading" do
    expect(rendered).to have_css "h1", text: "Are you sure you want to delete this draft?"
  end

  it "has a heading caption with the question text" do
    expect(rendered).to have_css ".govuk-caption-l", text: "Test form"
  end

  it "has a back link to the form page" do
    expect(view.content_for(:back_link)).to have_link "Back", href: "/forms/1"
  end

  it "has a delete confirmation input to confirm deletion of the form" do
    expect(rendered).to render_template "input_objects/_delete_confirmation_input"
  end

  describe "delete confirmation input" do
    it "posts the confirm value to the destroy action" do
      expect(rendered).to have_element "form", action: "/forms/1/delete", method: "post"
    end
  end
end
