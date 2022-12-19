require "rails_helper"

describe "pages/_form.html.erb", type: :view do
  let(:question) { build :page, :with_hints, :without_selection_answer_type, id: 1, form_id: 1 }
  let(:form) { build :form, id: 1, pages: [question] }
  let(:is_new_page) { true }

  before do
    render partial: "pages/form", locals: { is_new_page:,
                                            form_object: form,
                                            page_object: question,
                                            action_path: "http://example.com",
                                            change_answer_type_path: "http://change-me-please.com",
                                            change_selections_settings_path: "http://change-me-please.com",
                                            change_text_settings_path: "http://change-me-please.com" }
  end

  it "has a form with correct action" do
    expect(rendered).to have_selector('form[action="http://example.com"]')
  end

  it "has a hidden field for the answer type" do
    expect(rendered).to have_field("page[answer_type]", with: question.answer_type, type: :hidden)
  end

  it "has a field with the question text" do
    expect(rendered).to have_field(type: "text", with: question.question_text)
  end

  it "has a field with the hint text" do
    expect(rendered).to have_field(type: "text", with: question.hint_text)
  end

  it "has an unchecked optional checkbox" do
    expect(rendered).to have_unchecked_field("page[is_optional]")
  end

  it "has a link to change the answer type" do
    expect(rendered).to have_link(text: "Change", href: "http://change-me-please.com")
  end

  it "has a submit button with the correct text" do
    expect(rendered).to have_button("Save and add next question")
  end

  it "does not have a delete button" do
    expect(rendered).not_to have_button("delete")
  end

  context "when it is not a new page" do
    let(:is_new_page) { false }

    it "has no hidden field for the answer type" do
      expect(rendered).not_to have_field("page[answer_type]", type: :hidden)
    end

    it "has a delete button" do
      expect(rendered).to have_button("delete")
    end
  end
end
