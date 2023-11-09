require "rails_helper"

describe "pages/_form.html.erb", type: :view do
  let(:page) { build :page, :with_hints, :with_simple_answer_type, id: 2, form_id: form.id }
  let(:question_form) do
    build :question_form,
          answer_type: page.answer_type,
          question_text: page.question_text,
          hint_text: page.hint_text
  end
  let(:form) { build :form, id: 1 }
  let(:is_new_page) { true }

  before do
    render partial: "pages/form", locals: { is_new_page:,
                                            form_object: form,
                                            page_object: page,
                                            question_form:,
                                            action_path: "http://example.com",
                                            change_answer_type_path: "http://change-me-please.com",
                                            change_selections_settings_path: "http://change-me-please.com",
                                            change_text_settings_path: "http://change-me-please.com",
                                            change_date_settings_path: "http://change-me-please.com",
                                            change_address_settings_path: "http://change-me-please.com",
                                            change_name_settings_path: "http://change-me-please.com" }
  end

  it "has a form with correct action" do
    expect(rendered).to have_selector('form[action="http://example.com"]')
  end

  it "has a field with the question text" do
    expect(rendered).to have_field(type: "text", with: question_form.question_text)
  end

  it "has a field with the hint text" do
    expect(rendered).to have_field(type: "textarea", with: question_form.hint_text)
  end

  it "has an unchecked optional checkbox" do
    expect(rendered).to have_unchecked_field("pages_question_form[is_optional]")
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

  it "contains a link to add guidance" do
    expect(rendered).to have_link(text: I18n.t("guidance.add_guidance"), href: guidance_new_path(form_id: form.id))
  end

  context "when it is not a new page" do
    let(:is_new_page) { false }

    it "contains a link to add guidance" do
      expect(rendered).to have_link(text: I18n.t("guidance.add_guidance"), href: guidance_edit_path(form_id: form.id, page_id: page.id))
    end

    it "has no hidden field for the answer type" do
      expect(rendered).not_to have_field("question_form[answer_type]", type: :hidden)
    end

    it "has a delete button" do
      expect(rendered).to have_button("delete")
    end
  end
end
