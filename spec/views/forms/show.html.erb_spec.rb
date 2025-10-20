require "rails_helper"

describe "forms/show.html.erb" do
  let(:user) { build :user }
  let(:form) { create :form, :with_pages, name: "Form 1", form_slug: "form-1" }
  let(:group) { create :group, name: "Group 1" }

  before do
    assign(:current_user, user)
    assign(:task_status_counts, { completed: 12, total: 20 })
    without_partial_double_verification do
      allow(view).to receive(:current_form).and_return(form)
    end

    if group.present?
      GroupForm.create!(form_id: form.id, group_id: group.id)
    end

    render template: "forms/show"
  end

  it "contains page heading and sub-heading" do
    expect(rendered).to have_css("h1 .govuk-caption-l", text: "Form 1")
    expect(rendered).to have_css("h1.govuk-heading-l", text: /Create a form/)
  end

  it "contains a link to preview the form" do
    expect(rendered).to have_link("Preview this form", href: "runner-host/preview-draft/#{form.id}/form-1", visible: :all)
  end

  it "contains a link to delete the form" do
    expect(rendered).to have_link("Delete draft form", href: delete_form_path(form.id))
  end

  it "contains a summary of completed tasks out of the total tasks" do
    expect(rendered).to have_selector(".app-task-list__summary", text: "You’ve completed 12 of 20 tasks.")
  end

  it "rendered draft tag" do
    expect(rendered).to have_css(".govuk-tag.govuk-tag--yellow", text: "Draft")
  end

  it "has a back link to the group page" do
    expect(view.content_for(:back_link)).to have_link("Back to Group 1", href: group_path(group))
  end

  context "when a form is not in a group" do
    let(:group) { nil }

    it "has a back link to the forms page" do
      expect(view.content_for(:back_link)).to have_link("Back to your forms", href: "/")
    end
  end

  context "when form state is live or draft_live" do
    let(:form) { create :form, :live }

    it "has a back link to the live form page" do
      expect(view.content_for(:back_link)).to have_link("Back", href: "/forms/#{form.id}/live")
    end

    it "has the heading 'Edit your form'" do
      expect(rendered).to have_css("h1.govuk-heading-l", text: /Edit your form/)
    end

    it "rendered draft tag" do
      expect(rendered).to have_css(".govuk-tag.govuk-tag--yellow", text: "Draft")
    end

    it "does not contain a link to delete the form" do
      expect(rendered).not_to have_link("Delete draft form", href: delete_form_path(2))
    end

    context "and it's not in a group" do
      let(:group) { nil }

      it "has a back link to the live form page" do
        expect(view.content_for(:back_link)).to have_link("Back", href: "/forms/#{form.id}/live")
      end
    end
  end

  context "when the form state is live_with_draft" do
    let(:form) { create(:form, :live_with_draft) }

    it "contains a link to delete the draft form" do
      expect(rendered).to have_link("Delete draft form", href: delete_form_path(form.id))
    end
  end

  context "when form state is archived" do
    let(:form) { create :form, :archived }

    it "has a back link to the archived form page" do
      expect(view.content_for(:back_link)).to have_link("Back", href: "/forms/#{form.id}/archived")
    end

    it "has the heading 'Edit your form'" do
      expect(rendered).to have_css("h1.govuk-heading-l", text: /Edit your form/)
    end

    it "rendered draft tag" do
      expect(rendered).to have_css(".govuk-tag.govuk-tag--yellow", text: "Draft")
    end

    it "does not contain a link to delete the form" do
      expect(rendered).not_to have_link("Delete draft form", href: delete_form_path(2))
    end
  end

  context "when form state is archived with draft" do
    let(:form) { create :form, :archived_with_draft }

    it "does not contain a link to delete the form" do
      expect(rendered).not_to have_link("Delete draft form", href: delete_form_path(2))
    end
  end
end
