require "rails_helper"

describe "pages/_form.html.erb", type: :view do
  let(:page) { build :page, :with_hints, :with_simple_answer_type, id: 2, form_id: form.id }
  let(:draft_question) { question_input.draft_question }
  let(:question_input) do
    build :question_input,
          answer_type: page.answer_type,
          question_text: page.question_text,
          hint_text: page.hint_text
  end
  let(:form) { build :form, id: 1 }
  let(:is_new_page) { true }
  let(:locals) do
    { is_new_page:,
      form_object: form,
      page_object: page,
      draft_question:,
      question_input:,
      action_path: "http://example.com" }
  end

  before do
    render partial: "pages/form", locals:
  end

  it "has a form with correct action" do
    expect(rendered).to have_selector('form[action="http://example.com"]')
  end

  it "has a field with the question text" do
    expect(rendered).to have_field(type: "text", with: question_input.question_text)
  end

  it "has a field with the hint text" do
    expect(rendered).to have_field(type: "textarea", with: question_input.hint_text)
  end

  it "has an unchecked optional checkbox" do
    expect(rendered).to have_unchecked_field("pages_question_input[is_optional]")
  end

  it "has a submit button with the correct text" do
    expect(rendered).to have_button(I18n.t("pages.submit_save"))
  end

  it "does not have a delete button" do
    expect(rendered).not_to have_button("delete")
  end

  it "contains a link to add guidance" do
    expect(rendered).to have_link(text: I18n.t("guidance.add_guidance"), href: guidance_new_path(form_id: form.id))
  end

  context "when it is not a new page" do
    let(:is_new_page) { false }

    it "contains a link to add guidance" do
      expect(rendered).to have_link(text: I18n.t("guidance.add_guidance"), href: guidance_edit_path(form_id: 1, page_id: 2))
    end

    it "has no hidden field for the answer type" do
      expect(rendered).not_to have_field("question_input[answer_type]", type: :hidden)
    end

    it "has a delete button" do
      expect(rendered).to have_link(text: I18n.t("pages.delete_question"), href: delete_page_path(form_id: form.id, page_id: page.id))
    end
  end

  context "when the page has existing guidance" do
    let(:draft_question) { build :draft_question, :with_guidance }
    let(:question_input) do
      build :question_input,
            draft_question:,
            answer_type: page.answer_type,
            question_text: page.question_text,
            hint_text: page.hint_text
    end

    let(:guidance_service) { instance_double(PageSummaryData::GuidanceService) }
    let(:build_data) { {} }

    before do
      allow(guidance_service).to receive(:build_data).and_return(build_data)
      allow(PageSummaryData::GuidanceService).to receive(:call).and_return(guidance_service)

      render partial: "pages/form", locals:
    end

    it "calls the PageSummaryData::GuidanceService with the form and draft_question" do
      expect(PageSummaryData::GuidanceService).to have_received(:call).with(form:, draft_question:)
    end

    it "renders the draft question guidance page heading" do
      expect(rendered).to have_text(draft_question.page_heading)
    end

    it "renders the draft question guidance markdown" do
      expect(rendered).to have_text(draft_question.guidance_markdown)
    end
  end
end
