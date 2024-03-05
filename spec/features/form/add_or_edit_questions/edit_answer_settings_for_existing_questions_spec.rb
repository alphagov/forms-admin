require "rails_helper"

feature "Editing answer_settings for existing question", type: :feature do
  let(:form) { build :form, :with_active_resource, id: 1, pages: }

  before do
    ActiveResource::HttpMock.respond_to do |mock|
      mock.get "/api/v1/forms/1", headers, form.to_json, 200
      mock.get "/api/v1/forms/1/pages", headers, pages.to_json, 200
      mock.post "/api/v1/forms/1/pages", post_headers
      pages.each do |page|
        mock.get "/api/v1/forms/1/pages/#{page.id}", headers, page.to_json, 200
      end
    end

    login_as_editor_user
  end

  context "when a form has existing pages with answer types" do
    let(:address_question) { build(:page, :with_address_settings, form_id: 1) }
    let(:date_question) { build(:page, :with_date_settings, form_id: 1, input_type: "date_of_birth") }
    let(:name_question) { build(:page, :with_name_settings, form_id: 1, input_type: "first_middle_and_last_name", title_needed: "true") }
    let(:selection_question) { build(:page, :with_selections_settings, form_id: 1, is_optional: true) }
    let(:text_question) { build(:page, :with_text_settings, form_id: 1, input_type: "long_text") }
    let(:pages) { [address_question, date_question, name_question, selection_question, text_question] }

    scenario "view answer_settings for each answer type and check the values are set" do
      when_i_viewing_an_existing_form
      and_i_view_a_list_of_existing_questions

      pages.each do |question|
        and_i_want_to_edit(question)
        then_i_want_change_answer_settings_for(question)
        and_i_should_see_the_previous_values(question)
        then_go_back_to_list_of_questions
      end
    end
  end

private

  def when_i_viewing_an_existing_form
    visit form_path(form.id)
    expect_page_to_have_no_axe_errors(page)
  end

  def and_i_view_a_list_of_existing_questions
    click_on "Add and edit your questions"
    expect(page.find("h1")).to have_text "Add and edit your questions"
    expect(page).to have_selector(".govuk-summary-list__row", count: 5)
    expect_page_to_have_no_axe_errors(page)
  end

  def and_i_want_to_edit(question)
    click_link "Edit", href: edit_question_path(form.id, question.id)
    expect(page.find("h1")).to have_text "Edit question"
    expect(find_field("pages_question_form[question_text]").value).to eq question.question_text
    expect_page_to_have_no_axe_errors(page)
  end

  def then_i_want_change_answer_settings_for(question)
    href = get_change_link_for(question)
    # Some "edit question" pages have multiple links to the same url.
    first(:link, "Change", href:).click
  end

  def get_change_link_for(question)
    case question.answer_type.to_sym
    when :address
      address_settings_edit_path(form_id: form.id, page_id: question.id)
    when :date
      date_settings_edit_path(form_id: form.id, page_id: question.id)
    when :name
      name_settings_edit_path(form_id: form.id, page_id: question.id)
    when :selection
      selections_settings_edit_path(form_id: form.id, page_id: question.id)
    when :text
      text_settings_edit_path(form_id: form.id, page_id: question.id)
    end
  end

  def and_i_should_see_the_previous_values(question)
    case question.answer_type.to_sym
    when :address
      check_address_answer_settings
    when :date
      check_date_answer_settings
    when :name
      check_name_answer_settings
    when :selection
      check_selection_answer_settings
    when :text
      check_text_answer_settings
    end
  end

  def then_go_back_to_list_of_questions
    click_on "Back to your questions"
  end

  def check_address_answer_settings
    expect(page.find("h1")).to have_text "What kind of addresses do you expect to receive?"
    expect_page_to_have_no_axe_errors(page)
    expect(page).to have_checked_field("UK addresses", visible: :all)
    expect(page).to have_checked_field("International addresses", visible: :all)
    click_button "Continue"
    expect(page.find(".govuk-summary-list")).to have_text "UK and international addresses"
  end

  def check_date_answer_settings
    expect(page.find("h1")).to have_text "Are you asking for someone’s date of birth?"
    expect_page_to_have_no_axe_errors(page)
    expect(page).to have_checked_field("pages_date_settings_form[input_type]", with: "date_of_birth", visible: :all)
    click_button "Continue"
    expect(page.find_all(".govuk-summary-list__value")[1]).to have_text "Yes"
  end

  def check_name_answer_settings
    expect(page.find("h1")).to have_text "Ask for a person’s name"
    expect_page_to_have_no_axe_errors(page)
    expect(page).to have_checked_field("pages_name_settings_form[input_type]", with: "first_middle_and_last_name", visible: :all)
    expect(page).to have_checked_field("pages_name_settings_form[title_needed]", with: "true", visible: :all)
    click_button "Continue"
    expect(page.find_all(".govuk-summary-list__value")[1]).to have_text "First, middle and last names in separate boxes"
    expect(page.find_all(".govuk-summary-list__value")[2]).to have_text "Yes"
  end

  def check_selection_answer_settings
    expect(page.find("h1")).to have_text "Create a list of options"
    expect_page_to_have_no_axe_errors(page)
    expect(page).to have_checked_field("People can only select one option", visible: :all)
    expect(page).to have_checked_field("Include an option for ‘None of the above’", visible: :all)
    expect(find_field("Option 1").value).to eq "Option 1"
    expect(find_field("Option 2").value).to eq "Option 2"
    click_button "Continue"
    expect(page.find_all(".govuk-summary-list__value")[1]).to have_text "Option 1, Option 2"
    expect(page.find_all(".govuk-summary-list__value")[2]).to have_text "Yes"
    expect(page.find_all(".govuk-summary-list__value")[3]).to have_text "Yes"
  end

  def check_text_answer_settings
    expect(page.find("h1")).to have_text "How much text will people need to provide?"
    expect_page_to_have_no_axe_errors(page)
    expect(page).to have_checked_field("pages_text_settings_form[input_type]", with: "long_text", visible: :all)
    click_button "Continue"
    expect(page.find_all(".govuk-summary-list__value")[1]).to have_text "More than a single line of text"
  end
end
