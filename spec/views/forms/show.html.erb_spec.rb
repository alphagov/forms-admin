require "rails_helper"

describe "forms/show.html.erb" do
  around do |example|
    ClimateControl.modify RUNNER_BASE: "runner-host" do
      example.run
    end
  end

  before do
    assign(:form, OpenStruct.new(id: 1, name: "Form 1", form_slug: "form-1", status: "draft"))
    render template: "forms/show"
  end

  it "contains page heading and sub-heading" do
    expect(rendered).to have_css("h1 .govuk-caption-l", text: "Form 1")
    expect(rendered).to have_css("h1.govuk-heading-l", text: /Create a form/)
  end

  it "contains a link to preview the form" do
    expect(rendered).to have_link("Preview this form", href: "runner-host/preview-form/1/form-1", visible: :all)
  end

  it "contains a link to delete the form" do
    expect(rendered).to have_link("Delete form", href: delete_form_path(1))
  end

  describe "form states" do
    it "rendered draft tag " do
      assign(:form, OpenStruct.new(id: 1, name: "Form 1", form_slug: "form-1", status: "draft"))
      render template: "forms/show"
      expect(rendered).to have_css(".govuk-tag.govuk-tag--purple", text: "DRAFT")
    end

    it "rendered live tag" do
      assign(:form, OpenStruct.new(id: 1, name: "Form 1", form_slug: "form-1", status: "live"))
      render template: "forms/show"
      expect(rendered).to have_css(".govuk-tag.govuk-tag--blue", text: "LIVE")
    end
  end
end
