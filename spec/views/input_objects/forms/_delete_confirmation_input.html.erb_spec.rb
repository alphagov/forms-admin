require "rails_helper"

RSpec.describe "input_objects/forms/_delete_confirmation_input" do
  before do
    delete_confirmation_input = Forms::DeleteConfirmationInput.new
    url = delete_form_path(form_id: 1)
    caption_text = "Test form"
    legend_text = "Are you sure you want to delete this draft?"

    render locals: { delete_confirmation_input:, url:, caption_text:, legend_text: }
  end

  it "posts the confirm value to the destroy action" do
    expect(rendered).to have_element "form", action: "/forms/1/delete", method: "post"
  end

  it "has radio buttons to set confirmation to yes or no" do
    expect(rendered).to have_field "Yes", type: "radio", name: "forms_delete_confirmation_input[confirm]"
    expect(rendered).to have_field "No", type: "radio", name: "forms_delete_confirmation_input[confirm]"
  end

  it "has a legend for the radio buttons" do
    expect(rendered).to have_css "fieldset legend:has(~ .govuk-radios)", text: "Are you sure you want to delete this draft?"
  end

  it "has a submit button" do
    expect(rendered).to have_button "Continue", class: "govuk-button"
  end
end
