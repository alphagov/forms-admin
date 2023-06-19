require "rails_helper"

feature "Add/editing a single question", type: :feature do
  let(:form) { build :form, id: 1 }
  let(:req_headers) do
    {
      "X-API-Token" => Settings.forms_api.auth_key,
      "Accept" => "application/json",
    }
  end
  let(:post_headers) do
    {
      "X-API-Token" => Settings.forms_api.auth_key,
      "Content-Type" => "application/json",
    }
  end

  before do
    ActiveResource::HttpMock.respond_to do |mock|
      mock.get "/api/v1/forms/1", req_headers, form.to_json, 200
      mock.get "/api/v1/forms/1/pages", req_headers, pages.to_json, 200
      mock.post "/api/v1/forms/1/pages", post_headers
    end
  end

  context "when a form has no existing pages" do
    let(:pages) { [] }
    let(:answer_types) { %w[organisation_name email phone_number national_insurance_number address date selection number text] }

    scenario "add a question for each type of answer" do
      answer_types.each do |answer_type|
        when_i_viewing_an_existing_form
        and_i_want_to_create_or_edit_a_page
        and_i_select_a_type_of_answer_option(answer_type)
        and_i_provide_a_question_text
        and_i_save_and_create_another
      end
    end
  end

  context "when a form has existing pages" do
    let(:pages) do
      existing_pages = []
      5.times { |id| existing_pages.push(build(:page, id:, form_id: 1)) }
      existing_pages
    end
    let(:answer_types) { %w[organisation_name email phone_number national_insurance_number address date selection number text] }

    scenario "add a question for each type of answer" do
      answer_types.each do |answer_type|
        when_i_viewing_an_existing_form
        and_i_want_to_create_or_edit_a_page
        and_i_can_see_a_list_of_existing_pages
        and_i_start_adding_a_new_question
        and_i_select_a_type_of_answer_option(answer_type)
        and_i_provide_a_question_text
        and_i_save_and_create_another
      end
    end
  end

private

  def when_i_viewing_an_existing_form
    visit form_path(form.id)
  end

  def and_i_want_to_create_or_edit_a_page
    click_on "Add and edit your questions"
  end

  def and_i_select_a_type_of_answer_option(answer_type)
    expect(page.find("h1")).to have_text "What kind of answer do you need to this question?"
    choose I18n.t("helpers.label.page.answer_type_options.names.#{answer_type}")
    click_button "Continue"
    fill_in_question_text if answer_type == "selection"
    fill_in_selection_settings if answer_type == "selection"
    fill_in_text_settings if answer_type == "text"
    fill_in_date_settings if answer_type == "date"
    fill_in_address_settings if answer_type == "address"
    fill_in_name_settings if answer_type == "name"
    expect(page.find("h1")).to have_content "Edit question"
  end

  def and_i_provide_a_question_text
    fill_in "Question text", with: "What is your name?"
  end

  def and_i_save_and_create_another
    click_button "Save and add next question"
    expect(page.find("h1")).to have_text "What kind of answer do you need to this question?"
    expect(page).not_to have_selector("main input:checked", visible: :hidden), "Type of answer page should not have any preselected radio buttons"
  end

  def and_i_can_see_a_list_of_existing_pages
    expect(page.find("h1")).to have_text "Add and edit your questions"
    expect(page).to have_selector(".govuk-summary-list__row", count: 5)
  end

  def and_i_start_adding_a_new_question
    click_link "Add a question"
  end

  def fill_in_question_text
    expect(page.find("h1")).to have_text "What’s your question?"
    fill_in "What’s your question?", with: "What is your name?"
    click_button "Continue"
  end

  def fill_in_selection_settings
    expect(page.find("h1")).to have_text "Create a list of options"
    check "Include an option for ‘None of the above’"
    fill_in "Option 1", with: "Checkbox option 1"
    fill_in "Option 2", with: "Checkbox option 2"
    click_button "Add another option"
    fill_in "Option 3", with: "Checkbox option 3"
    click_button "Continue"
    click_link "Change Options"
    expect(page.find("h1")).to have_text "Create a list of options"
    check "People can only select one option"
    uncheck "Include an option for ‘None of the above’"
    click_button "Remove option 3"
    fill_in "Option 1", with: "Radio option 1"
    fill_in "Option 2", with: "Radio option 2"
    click_button "Continue"
  end

  def fill_in_text_settings
    expect(page.find("h1")).to have_text "How much text will people need to provide?"
    choose "Single line of text"
    click_button "Continue"
  end

  def fill_in_date_settings
    expect(page.find("h1")).to have_text "Are you asking for someone’s date of birth?"
    choose "No"
    click_button "Continue"
  end

  def fill_in_address_settings
    expect(page.find("h1")).to have_text "What kind of addresses do you expect to receive?"
    check "UK addresses"
    check "International addresses"
    click_button "Continue"
    expect(page.find(".govuk-summary-list")).to have_text "UK and international addresses"
  end

  def fill_in_name_settings
    expect(page.find("h1")).to have_text "Ask for a person’s name"
    within_fieldset("How do you need to collect the name?") { choose("Full name in a single box") }
    within_fieldset("Do you need the person’s title?") { choose("No") }
    click_button "Continue"
    expect(page.find(".govuk-summary-list")).to have_text "Full name in a single box"
  end
end
