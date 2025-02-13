require "rails_helper"

describe "pages/routes/delete.html.erb" do
  let(:form) { build :form, id: 1, pages: [ page ] }
  let(:page) { build :page, id: 1, position: 1 }

  before do
    render template: "pages/routes/delete", locals: { current_form: form, page:, delete_confirmation_input: Pages::Routes::DeleteConfirmationInput.new }
  end

  it "has the correct title" do
    expect(view.content_for(:title)).to have_content(I18n.t("pages.routes.delete.title", page_number: 1))
  end

  it "has the correct back link" do
    expect(view.content_for(:back_link)).to have_link(I18n.t("pages.routes.delete.back", page_number: form.page_number(page)), href: show_routes_path(form_id: form.id, page_id: page.id))
  end

  it "has the correct heading" do
    expect(rendered).to have_selector("h1", text: I18n.t("pages.routes.delete.title", page_number: 1))
  end

  it "posts the confirm value to the destroy action" do
    expect(rendered).to have_element "form", action: destroy_routes_path(form.id, page.id), method: "post"
  end

  it "has radio buttons to set confirmation to yes or no" do
    expect(rendered).to have_field "Yes", type: "radio", name: "pages_routes_delete_confirmation_input[confirm]"
    expect(rendered).to have_field "No", type: "radio", name: "pages_routes_delete_confirmation_input[confirm]"
  end

  it "has a legend for the radio buttons" do
    expect(rendered).to have_css "fieldset legend:has(~ .govuk-radios)", text: I18n.t("pages.routes.delete.title", page_number: 1)
  end

  it "has a submit button" do
    expect(rendered).to have_button I18n.t("save_and_continue"), type: "submit"
  end
end
