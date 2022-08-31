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
      ClimateControl.modify RUNNER_BASE: "api-host" do
        example.run
      end
    end

    before do
      assign(:forms, [OpenStruct.new(id: 1, name: "Form 1"), OpenStruct.new(id: 2, name: "Form 2")])
      render template: "home/index"
    end

    it "allows the user to create a new form" do
      expect(rendered).to have_link("Create a form", href: forms_new_path)
    end

    it "does contain a list of forms with actions" do
      expect(rendered).to have_text "Your forms"
      expect(rendered).to have_css ".govuk-summary-list .govuk-summary-list__row", count: 2
    end

    it "displays preview links for each form" do
      expect(rendered).to have_link("Preview this form : Form 1", href: "api-host/form/1", visible: :all)
      expect(rendered).to have_link("Preview this form : Form 2", href: "api-host/form/2", visible: :all)
    end
  end
end
