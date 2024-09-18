require "rails_helper"

describe "forms/receive_csv/new.html.erb" do
  let(:current_form) { OpenStruct.new(id: 1, name: "Form 1", form_slug: "form-1") }

  before do
    allow(view).to receive_messages(form_path: "/forms/1")
    render template: "forms/receive_csv/new"
  end

  it "has a back link to the form task list" do
    expect(view.content_for(:back_link)).to have_link("Back to create your form", href: form_path(current_form.id))
  end
end
