require "rails_helper"

describe "pages/guidance.html.erb", type: :view do
  let(:form) { build :form, id: 1 }
  let(:page) { OpenStruct.new(conditions: [], answer_type: "number") }
  let(:guidance_input) { Pages::GuidanceInput.new }
  let(:preview_html) { I18n.t("guidance.no_guidance_added_html") }
  let(:back_link) { "/forms/1/pages/new" }
  let(:question_number) { 1 }
  let(:is_new_page) { true }
  let(:guidance_input_path) { "/forms/1/pages/new/guidance" }

  before do
    # allow objects to use ids in form helper
    allow(guidance_input).to receive(:persisted?).and_return(true)

    # mock the form.page_number method
    allow(form).to receive_messages(persisted?: true, page_number: question_number)

    # mock the path helper
    without_partial_double_verification do
      allow(view).to receive_messages(form_pages_guidance_input_path: guidance_input_path, current_form: form)
    end

    # setup instance variables
    assign(:page, page)
    assign(:guidance_input, guidance_input)

    render(template: "pages/guidance", locals: { guidance_input:, back_link:, post_url: guidance_input_path, form:, page:, preview_html: })
  end

  it "has the correct title" do
    expect(view.content_for(:title)).to have_content(I18n.t("page_titles.add_guidance"))
  end

  it "has a back link to the live form page" do
    expect(view.content_for(:back_link)).to have_link("Back", href: back_link)
  end

  it "contains the question number" do
    expect(rendered).to have_content("Question #{question_number}")
  end

  it "has the correct heading and caption" do
    expect(rendered).to have_selector("h1", text: "Question #{question_number}")
    expect(rendered).to have_selector("h1", text: I18n.t("guidance.add_guidance"))
  end

  it "contains a form which submits to @guidance_input_path" do
    expect(rendered).to have_selector("form[action=\"#{guidance_input_path}\"]")
  end
end
