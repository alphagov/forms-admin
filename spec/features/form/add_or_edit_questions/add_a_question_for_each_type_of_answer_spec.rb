require "rails_helper"

feature "Add/editing a single question", type: :feature do
  let(:form) { build :form, :with_active_resource, id: 1 }
  let(:fake_page) { build :page, form_id: 1, id: 2 }
  let(:group) { create(:group, organisation: standard_user.organisation) }

  before do
    ActiveResource::HttpMock.respond_to do |mock|
      mock.get "/api/v1/forms/1", headers, form.to_json, 200
      mock.get "/api/v1/forms/1/pages", headers, pages.to_json, 200
      mock.get "/api/v1/forms/1/pages/2", headers, fake_page.to_json, 200
      mock.post "/api/v1/forms/1/pages", post_headers, fake_page.to_json, 200
      mock.put "/api/v1/forms/1", post_headers, form.to_json, 200
    end

    GroupForm.create!(group:, form_id: form.id)
    create(:membership, group:, user: standard_user, added_by: standard_user)

    login_as standard_user
  end

  context "when a form has no existing pages" do
    let(:pages) { [] }
    let(:answer_types) { %w[organisation_name email phone_number national_insurance_number address date selection number text] }

    scenario "add a question for each type of answer" do
      answer_types.each do |answer_type|
        when_i_am_viewing_an_existing_form
        and_i_want_to_create_or_edit_a_page
        and_i_select_a_type_of_answer_option(answer_type)
        and_i_provide_a_question_text
        and_i_make_the_question_mandatory unless answer_type == "selection"
        and_i_click_save
        and_i_add_another_question
      end
    end

    context "when the form is in a group which has long lists enabled" do
      let(:group) { create(:group, organisation: standard_user.organisation, long_lists_enabled: true) }
      let(:options) { 10.times.map { Faker::Name.unique.name } }

      scenario "add a selection question which the user can answer more than once" do
        when_i_am_viewing_an_existing_form
        and_i_want_to_create_or_edit_a_page
        and_i_select_selection_type_question
        and_i_select_people_can_choose_one_or_more_options
        and_i_configure_the_selection_options(options)
        and_i_click_save
        and_i_add_another_question
      end

      scenario "add a selection question which the user can answer once" do
        when_i_am_viewing_an_existing_form
        and_i_want_to_create_or_edit_a_page
        and_i_select_selection_type_question
        and_i_select_people_can_only_choose_one_option
        and_i_configure_the_selection_options(options)
        and_i_click_save
        and_i_add_another_question
      end
    end
  end

  context "when a form has existing pages" do
    let(:pages) do
      existing_pages = []
      5.times { |id| existing_pages.push(build(:page, id:, form_id: 1)) }
      existing_pages
    end

    scenario "add a question for each type of answer" do
      when_i_am_viewing_an_existing_form
      and_i_want_to_create_or_edit_a_page
      and_i_can_see_a_list_of_existing_pages
      and_i_start_adding_a_new_question
      and_i_select_a_type_of_answer_option("national_insurance_number")
      and_i_provide_a_question_text
      and_i_make_the_question_mandatory
      and_i_click_save
      and_i_click_back_to_your_questions
      and_i_mark_the_questions_section_as_complete
    end
  end

private

  def when_i_am_viewing_an_existing_form
    visit form_path(form.id)
    expect_page_to_have_no_axe_errors(page)
  end

  def and_i_want_to_create_or_edit_a_page
    click_on "Add and edit your questions"
  end

  def and_i_select_a_type_of_answer_option(answer_type)
    expect(page.find("h1")).to have_text "What kind of answer do you need to this question?"
    expect_page_to_have_no_axe_errors(page)
    choose I18n.t("helpers.label.page.answer_type_options.names.#{answer_type}")
    click_button "Continue"
    fill_in_question_text if answer_type == "selection"
    fill_in_selection_settings if answer_type == "selection"
    fill_in_text_settings if answer_type == "text"
    fill_in_date_settings if answer_type == "date"
    fill_in_address_settings if answer_type == "address"
    fill_in_name_settings if answer_type == "name"
    expect(page.find("h1")).to have_content "Edit question"
    expect_page_to_have_no_axe_errors(page)
  end

  def and_i_provide_a_question_text
    fill_in "Question text", with: "What is your name?"
  end

  def and_i_make_the_question_mandatory
    within_fieldset("Should this question be mandatory or optional?") { choose "Mandatory" }
  end

  def and_i_click_save
    click_button I18n.t("pages.submit_save")
    expect(page.find(".govuk-notification-banner__title")).to have_text("Success")
  end

  def and_i_add_another_question
    within(page.find(".govuk-notification-banner__content")) do
      click_on "Add a question"
    end
    expect(page.find("h1")).to have_text "What kind of answer do you need to this question?"
    expect(page).not_to have_selector("main input:checked", visible: :hidden), "Type of answer page should not have any preselected radio buttons"
    expect_page_to_have_no_axe_errors(page)
  end

  def and_i_click_back_to_your_questions
    page.find(".govuk-notification-banner ").click_link "Back to your questions"
    expect(page.find("h1")).to have_text("Add and edit your questions")
  end

  def and_i_mark_the_questions_section_as_complete
    expect(page.find("h1")).to have_text("Add and edit your questions")
    choose "Yes"
    click_button "Save and continue"
    expect(page.find("h1")).to have_text("Create a form")
    expect(page.find(".govuk-notification-banner__heading")).to have_text("Your questions have been saved and marked as complete")
  end

  def and_i_can_see_a_list_of_existing_pages
    expect(page.find("h1")).to have_text "Add and edit your questions"
    expect(page).to have_selector(".govuk-summary-list__row", count: 5)
    expect_page_to_have_no_axe_errors(page)
  end

  def and_i_start_adding_a_new_question
    click_link "Add a question"
  end

  def fill_in_question_text
    expect(page.find("h1")).to have_text "What’s your question?"
    expect_page_to_have_no_axe_errors(page)
    fill_in "What’s your question?", with: "What is your name?"
    click_button "Continue"
  end

  def fill_in_selection_settings
    expect(page.find("h1")).to have_text "Create a list of options"
    expect_page_to_have_no_axe_errors(page)
    check "Include an option for ‘None of the above’"
    fill_in "Option 1", with: "Checkbox option 1"
    fill_in "Option 2", with: "Checkbox option 2"
    click_button "Add another option"
    fill_in "Option 3", with: "Checkbox option 3"
    click_button "Continue"
    click_link "Change Options"
    expect(page.find("h1")).to have_text "Create a list of options"
    expect_page_to_have_no_axe_errors(page)
    check "People can only select one option"
    uncheck "Include an option for ‘None of the above’"
    click_button "Remove option 3"
    fill_in "Option 1", with: "Radio option 1"
    fill_in "Option 2", with: "Radio option 2"
    click_button "Continue"
  end

  def fill_in_text_settings
    expect(page.find("h1")).to have_text "How much text will people need to provide?"
    expect_page_to_have_no_axe_errors(page)
    choose "Single line of text"
    click_button "Continue"
  end

  def fill_in_date_settings
    expect(page.find("h1")).to have_text "Are you asking for someone’s date of birth?"
    expect_page_to_have_no_axe_errors(page)
    choose "No"
    click_button "Continue"
  end

  def fill_in_address_settings
    expect(page.find("h1")).to have_text "What kind of addresses do you expect to receive?"
    expect_page_to_have_no_axe_errors(page)
    check "UK addresses"
    check "International addresses"
    click_button "Continue"
    expect(page.find(".govuk-summary-list")).to have_text "UK and international addresses"
  end

  def fill_in_name_settings
    expect(page.find("h1")).to have_text "Ask for a person’s name"
    expect_page_to_have_no_axe_errors(page)
    within_fieldset("How do you need to collect the name?") { choose("Full name in a single box") }
    within_fieldset("Do you need the person’s title?") { choose("No") }
    click_button "Continue"
    expect(page.find(".govuk-summary-list")).to have_text "Full name in a single box"
  end

  def and_i_click_back_to_your_questions
    page.find(".govuk-notification-banner ").click_link "Back to your questions"
    expect(page.find("h1")).to have_text("Add and edit your questions")
  end

  def and_i_select_selection_type_question
    expect(page.find("h1")).to have_text "What kind of answer do you need to this question?"
    expect_page_to_have_no_axe_errors(page)
    choose I18n.t("helpers.label.page.answer_type_options.names.selection")
    click_button "Continue"
    fill_in_question_text
  end

  def and_i_select_people_can_only_choose_one_option
    expect(page.find("h1")).to have_text "How many options should people be able to select?"
    expect_page_to_have_no_axe_errors(page)
    choose "People can select only one option"
    click_button "Continue"
  end

  def and_i_select_people_can_choose_one_or_more_options
    expect(page.find("h1")).to have_text "How many options should people be able to select?"
    expect_page_to_have_no_axe_errors(page)
    choose "People can select one or more options"
    click_button "Continue"
  end

  def and_i_configure_the_selection_options(options)
    fill_in_selection_options(options)
    fill_in_bulk_options(options)
  end

  def fill_in_selection_options(options)
    expect(page.find("h1")).to have_text "Create a list of options"
    expect_page_to_have_no_axe_errors(page)
    fill_in "Option 1", with: options[0]
    fill_in "Option 2", with: options[1]
    click_button "Add another option"
    fill_in "Option 3", with: options[2]
    choose "Yes"
    click_button "Continue"

    click_link "Change Options"
    expect(page.find("h1")).to have_text "Create a list of options"
    expect_page_to_have_no_axe_errors(page)
    choose "No"
    click_button "Remove option 3"
  end

  def fill_in_bulk_options(options)
    click_link "Enter all the options into one text box"
    expect(page.find("h1")).to have_text("Create a list of options")
    expect_page_to_have_no_axe_errors(page)
    fill_in "Enter the options for your list", with: options.join("\n")
    choose "Yes"
    click_button "Save and continue"
  end
end
