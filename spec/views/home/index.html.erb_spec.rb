require "rails_helper"

describe "home/index.html.erb" do
  describe "when there are no forms to display" do
    before do
      assign(:forms, [])
      render template: "home/index"
    end

    it "allows the user to create a new form" do
      expect(rendered).to have_link("Create a form", href: forms_new_path)
    end

    it "does not contain a a list of forms" do
      expect(rendered).not_to have_text "Your forms"
      expect(rendered).not_to have_css ".govuk-summary-list"
    end
  end

  describe "when there are one or more forms to display" do
    around do |example|
      ClimateControl.modify RUNNER_BASE: "runner-host" do
        example.run
      end
    end

    before do
      assign(:forms, [OpenStruct.new(id: 1, name: "Form 1", form_slug: "form-1", status: "draft"), OpenStruct.new(id: 2, name: "Form 2", form_slug: "form-2", status: "live")])
      render template: "home/index"
    end

    it "allows the user to create a new form" do
      expect(rendered).to have_link("Create a form", href: forms_new_path)
    end

    it "does contain a table listing the users forms and their status" do
      expect(rendered).to have_css(".govuk-table__caption", text: "Your forms")
      expect(rendered).to have_css "tbody .govuk-table__row", count: 2
    end

    it "displays links for each form" do
      expect(rendered).to have_link("Form 1", href: form_path(1))
      expect(rendered).to have_link("Form 2", href: form_path(2))
    end
  end
end
