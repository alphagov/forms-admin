require "rails_helper"

describe "forms/unarchive/unarchive_form.html.erb" do
  let(:current_form) { OpenStruct.new(id: 1, state: "archived", name: "Form 1", form_slug: "form-1") }

  before do
    assign(:make_live_input, Forms::MakeLiveInput.new(form: current_form))
    render template: "forms/unarchive/unarchive_form", locals: { current_form: }
  end

  it "has the correct heading" do
    expect(rendered).to have_css("h1", text: I18n.t("page_titles.unarchive_form"))
  end

  it "contains a radio question for choosing whether to make the form live" do
    expect(rendered).to have_css("fieldset", text: I18n.t("helpers.label.forms_make_live_input.confirm"))
    expect(rendered).to have_field("Yes", type: "radio")
    expect(rendered).to have_field("No", type: "radio")
  end
end
