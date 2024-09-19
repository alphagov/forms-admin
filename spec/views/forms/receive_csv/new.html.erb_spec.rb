require "rails_helper"

describe "forms/receive_csv/new.html.erb" do
  let(:current_form) { OpenStruct.new(id: 1, name: "Form 1", form_slug: "form-1") }
  let(:receive_csv_input) { Forms::ReceiveCsvInput.new(form: current_form).assign_form_values }

  before do
    assign(:receive_csv_input, receive_csv_input)
    allow(view).to receive_messages(form_path: "/forms/1", receive_csv_create_path: "/forms/1/receive-csv")
    render template: "forms/receive_csv/new"
  end

  it "has a back link to the form task list" do
    expect(view.content_for(:back_link)).to have_link("Back to create your form", href: form_path(current_form.id))
  end

  it "has a heading" do
    expect(rendered).to have_css("h1", text: I18n.t("forms.receive_csv.new.title"))
  end

  it "has body text" do
    expect(rendered).to include(I18n.t("forms.receive_csv.new.body_html"))
  end

  it "has a checkbox for setting the submission type" do
    expect(rendered).to have_css("fieldset", text: I18n.t("helpers.legend.forms_receive_csv_input.submission_type"))
    expect(rendered).to have_field(I18n.t("helpers.label.forms_receive_csv_input.submission_type_options.email_with_csv"), type: :checkbox)
  end

  it "has a submit button" do
    expect(rendered).to have_button(I18n.t("forms.receive_csv.new.submit"))
  end
end
