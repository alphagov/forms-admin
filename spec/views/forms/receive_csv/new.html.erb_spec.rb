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

  it "has a checkbox for setting the submission type" do
    expect(rendered).to have_field("Submission_type", type: :checkbox)
  end
end
