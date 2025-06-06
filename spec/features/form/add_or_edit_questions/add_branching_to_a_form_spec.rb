require "rails_helper"

feature "Adding branching to a form", type: :feature do
  let(:form) { build :form, :ready_for_api_routing, id: 1 }
  let(:pages) { form.pages }
  let(:group) { create(:group, organisation: standard_user.organisation) }
  let(:condition) { build(:condition, id: 1, form_id: 1, page_id: form.pages.first.id, check_page_id: form.pages.first.id, routing_page_id: form.pages.first.id, goto_page_id: form.pages.last.id, answer_value: form.pages.first.answer_settings.selection_options.first.attributes[:name]) }
  let(:secondary_skip_condition) { build(:condition, id: 2, form_id: 1, page_id: form.pages[3].id, check_page_id: form.pages.first.id, routing_page_id: form.pages[3].id, goto_page_id: nil, skip_to_end: true) }

  before do
    allow(FormRepository).to receive_messages(find: form)
    allow(ConditionRepository).to receive_messages(create!: true)

    pages.each do |page|
      allow(PageRepository).to receive(:find).with(page_id: page.id.to_s, form_id: 1).and_return(page)
    end

    GroupForm.create! group:, form_id: form.id
    create(:membership, group:, user: standard_user, added_by: standard_user)

    login_as standard_user
  end

  scenario "Adding branching to a form" do
    when_viewing_a_forms_questions
    and_i_add_a_route
    then_i_should_see_the_add_route_page
    and_i_select_a_question_and_continue
    then_i_should_see_the_new_condition_page
    and_i_select_an_answer_value_with_goto_page_and_continue
    then_i_should_see_the_routes_page
    and_i_select_set_questions_to_skip
    then_i_should_see_the_secondary_skip_page
    and_i_select_a_skip_page_and_goto_page
    then_i_should_see_the_secondary_skip_on_the_routes_page
  end

private

  def when_viewing_a_forms_questions
    visit form_pages_path(form.id)
    expect(page.find("h1")).to have_text "Add and edit your questions"
    expect(page).to have_selector(".govuk-summary-list__row", count: 5)
    expect_page_to_have_no_axe_errors(page)
  end

  def and_i_add_a_route
    click_on "Add a question route"
  end

  def then_i_should_see_the_add_route_page
    expect(page.find("h1")).to have_text "Add a route from a question"
    expect_page_to_have_no_axe_errors(page)
  end

  def and_i_select_a_question_and_continue
    choose form.pages.first.question_text.to_s
    click_on "Continue"
  end

  def then_i_should_see_the_new_condition_page
    expect(page.find("h1")).to have_text "Add route 1: select an answer and where to skip to"
    expect_page_to_have_no_axe_errors(page)
  end

  def and_i_select_an_answer_value_with_goto_page_and_continue
    select form.pages.first.answer_settings.selection_options.first.attributes[:name], from: "pages_conditions_input[answer_value]"
    select form.pages.last.question_text, from: "pages_conditions_input[goto_page_id]"
    form.pages.first.routing_conditions << condition
    click_on "Save and continue"
  end

  def then_i_should_see_the_routes_page
    expect(page.find("h1")).to have_text "Question 1’s routes"
    expect(page).to have_text "Route 1"
    expect(page).to have_text form.pages.first.answer_settings.selection_options.first.attributes[:name]
    expect(page).to have_text form.pages.last.question_text
    expect_page_to_have_no_axe_errors(page)
  end

  def and_i_select_set_questions_to_skip
    click_on "Set questions to skip"
  end

  def then_i_should_see_the_secondary_skip_page
    expect(page.find("h1")).to have_text "Route for any other answer: set questions to skip"
    expect(page).to have_text "Select the last question you want them to answer before they skip"
    expect(page).to have_text "Select the question to skip them to"
    expect_page_to_have_no_axe_errors(page)
  end

  def and_i_select_a_skip_page_and_goto_page
    select form.pages[3].question_text, from: "pages_secondary_skip_input[routing_page_id]"
    select "Check your answers before submitting", from: "pages_secondary_skip_input[goto_page_id]"
    form.pages[3].routing_conditions << secondary_skip_condition
    click_on "Save and continue"
  end

  def then_i_should_see_the_secondary_skip_on_the_routes_page
    expect(page).to have_text "Route for any other answer"
    expect(page).to have_text "Continue to"
    expect(page).to have_text form.pages[3].question_text
    expect(page).to have_text "Check your answers before submitting"
    expect_page_to_have_no_axe_errors(page)
  end
end
