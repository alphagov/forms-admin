require "rails_helper"

describe "forms/make_live/make_your_changes_to_english_live.html.erb" do
  let(:current_form) { OpenStruct.new(id: 1, name: "Form 1", form_slug: "form-1") }

  before do
    without_partial_double_verification do
      allow(view).to receive_messages(form_path: "/forms/1")
    end

    assign(:current_form, current_form)

    render template: "forms/make_live/make_your_changes_to_english_live", locals: { current_form: }
  end

  it "has the correct page title" do
    expect(view.content_for(:title)).to eq t("page_titles.make_your_changes_to_english_live")
  end

  it "contains a heading" do
    expect(rendered).to have_css("h1", text: t("page_titles.make_your_changes_to_english_live"))
  end

  it "contains a link to edit the form" do
    expect(rendered).to have_link("Continue editing your form", href: "/forms/1")
  end
end
