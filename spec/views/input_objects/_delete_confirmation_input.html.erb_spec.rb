require "rails_helper"

RSpec.describe "input_objects/_delete_confirmation_input" do
  before do
    delete_confirmation_input = DeleteConfirmationInput.new
    url = "/delete"
    caption_text = "Thing"
    legend_text = "Are you sure you want to delete this thing?"

    render locals: { delete_confirmation_input:, url:, caption_text:, legend_text: }
  end

  it "posts the confirm value to the destroy action" do
    expect(rendered).to have_element("form", action: "/delete") do |form|
      expect(form).to have_field "_method", type: "hidden", with: "delete"
    end
  end

  it "has radio buttons to set confirmation to yes or no" do
    expect(rendered).to have_field "Yes", type: "radio", name: "delete_confirmation_input[confirm]"
    expect(rendered).to have_field "No", type: "radio", name: "delete_confirmation_input[confirm]"
  end

  it "has a legend for the radio buttons" do
    expect(rendered).to have_css "fieldset legend:has(~ .govuk-radios)", text: "Are you sure you want to delete this thing?"
  end

  it "has a submit button" do
    expect(rendered).to have_button "Continue", class: "govuk-button"
  end
end
