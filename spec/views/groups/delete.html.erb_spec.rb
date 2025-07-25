require "rails_helper"

RSpec.describe "groups/delete", type: :view do
  let(:delete_confirmation_input) { Groups::DeleteConfirmationInput.new }
  let(:group) { create :group, name: "Test Group" }

  before do
    assign(:delete_confirmation_input, delete_confirmation_input)
    assign(:group, group)

    render
  end

  it "has a page title" do
    expect(view.content_for(:title)).to include "Are you sure you want to delete this group?"
  end

  it "has a back link" do
    expect(view.content_for(:back_link)).to have_link "Back to Test Group", href: group_path(group)
  end

  it "has a heading" do
    expect(rendered).to have_css "h1", text: "Are you sure you want to delete this group?"
  end

  it "has a heading caption with the group name" do
    expect(rendered).to have_css ".govuk-caption-l", text: "Test Group"
  end

  it "has a delete confirmation input" do
    expect(rendered).to render_template "input_objects/_delete_confirmation_input"
  end

  describe "delete confirmation input" do
    it "posts the confirm value to the destroy action" do
      expect(rendered).to have_element "form", action: "/groups/#{group.external_id}" do |form|
        expect(form).to have_field "_method", type: "hidden", with: "delete"
      end
    end
  end

  context "when there is an error" do
    context "when the user has not confirmed whether or not they want to delete the group" do
      let(:delete_confirmation_input) do
        delete_confirmation_input = Groups::DeleteConfirmationInput.new confirm: nil
        delete_confirmation_input.validate
        delete_confirmation_input
      end

      it "has error in the page title" do
        expect(view.content_for(:title)).to start_with "Error: "
      end

      it "has an error message" do
        expect(rendered).to have_css ".govuk-error-message", text: "Select ‘Yes’ to delete the group"
      end
    end
  end
end
