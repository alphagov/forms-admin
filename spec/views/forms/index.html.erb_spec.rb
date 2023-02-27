require "rails_helper"

describe "forms/index.html.erb" do
  let(:forms) { [] }

  before do
    assign(:forms, forms)
    render template: "forms/index"
  end

  describe "when there are no forms to display" do
    it "allows the user to create a new form" do
      expect(rendered).to have_link("Create a form", href: forms_new_path)
    end

    it "does not contain a a list of forms" do
      expect(rendered).not_to have_text "Your forms"
      expect(rendered).not_to have_css ".govuk-summary-list"
    end
  end

  describe "when there are one or more forms to display" do
    let(:forms) { [OpenStruct.new(id: 1, name: "Form 1", form_slug: "form-1", status: "draft"), OpenStruct.new(id: 2, name: "Form 2", form_slug: "form-2", status: "live")] }

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

    context "when a form is live renders link to 'live' form readonly view" do
      let(:forms) { [OpenStruct.new(id: 1, name: "Form 1", form_slug: "form-1", status: "draft", live?: false), OpenStruct.new(id: 2, name: "Form 2", form_slug: "form-2", status: "live", live?: true)] }

      it "allows the user to create a new form" do
        expect(rendered).to have_link("Create a form", href: forms_new_path)
      end

      it "does contain a table listing the users forms and their status" do
        expect(rendered).to have_css(".govuk-table__caption", text: "Your forms")
        expect(rendered).to have_css "tbody .govuk-table__row", count: 2
      end

      it "displays links for each form" do
        expect(rendered).to have_link("Form 1", href: form_path(1))
        expect(rendered).to have_link("Form 2", href: live_form_path(2))
      end
    end
  end
end
