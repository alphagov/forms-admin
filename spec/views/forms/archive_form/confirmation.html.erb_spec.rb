require "rails_helper"

describe "forms/archive_form/confirmation.html.erb" do
  let(:id) { 2 }
  let(:form) { build(:form, :live, id:) }

  before do
    render(template: "forms/archive_form/confirmation", locals: { form: })
  end

  it "contains a confirmation panel with title" do
    expect(rendered).to have_css(".govuk-panel--confirmation h1", text: "Your form has been archived")
  end

  it "has link to archived form" do
    expect(rendered).to have_link("Continue to form details", href: archived_form_path(id))
  end
end
