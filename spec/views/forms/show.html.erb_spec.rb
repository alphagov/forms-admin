require "rails_helper"

describe "forms/show.html.erb" do
  let(:pages) { [{ id: 183, question_text: "What is your address?", question_short_name: nil, hint_text: "", answer_type: "address", next_page: nil }] }

  before do
    assign(:form, OpenStruct.new(id: 1, name: "Form 1", form_slug: "form-1", status: "draft", pages:))
    render template: "forms/show"
  end

  it "contains page heading and sub-heading" do
    expect(rendered).to have_css("h1 .govuk-caption-l", text: "Form 1")
    expect(rendered).to have_css("h1.govuk-heading-l", text: /Create a form/)
  end

  it "contains a link to preview the form" do
    expect(rendered).to have_link("Preview this form", href: "http://runner-host/preview-form/1/form-1", visible: :all)
  end

  it "contains a link to delete the form" do
    expect(rendered).to have_link("Delete form", href: delete_form_path(1))
  end

  describe "form states" do
    it "rendered draft tag " do
      assign(:form, OpenStruct.new(id: 1, name: "Form 1", form_slug: "form-1", status: "draft", pages: []))
      render template: "forms/show"
      expect(rendered).to have_css(".govuk-tag.govuk-tag--purple", text: "DRAFT")
    end

    it "rendered live tag" do
      assign(:form, OpenStruct.new(id: 1, name: "Form 1", form_slug: "form-1", status: "live", pages: []))
      render template: "forms/show"
      expect(rendered).to have_css(".govuk-tag.govuk-tag--blue", text: "LIVE")
    end
  end
end
