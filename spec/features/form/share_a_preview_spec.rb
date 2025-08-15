require "rails_helper"

feature "Share a preview", type: :feature do
  let(:form) { build :form, :with_pages, id: 1, name: "Test form" }
  let(:group) { create(:group, organisation: standard_user.organisation, status: "active") }
  let(:fake_page) { build :page, form_id: form.id, id: 2 }

  before do
    allow(FormRepository).to receive_messages(find: form, save!: form, pages: form.pages)
    allow(PageRepository).to receive(:find).with(page_id: "2", form_id: 1).and_return(fake_page)
    allow(PageRepository).to receive(:create!).with(hash_including(form_id: 1))

    GroupForm.create!(group:, form_id: form.id)
    create(:membership, group:, user: standard_user, added_by: standard_user, role: :group_admin)

    login_as standard_user
  end

  scenario "as a form editor" do
    given_i_am_viewing_a_form
    when_i_click_share_a_preview
    then_i_am_shown_the_share_a_preview_page
    when_i_click_the_copy_to_clipboard_button
    then_the_preview_url_is_copied_to_my_clipboard
    when_i_mark_the_task_complete
    then_i_am_returned_to_the_form_page
    then_i_see_a_success_message
  end

  def given_i_am_viewing_a_form
    visit form_path(form.id)
    expect(page.find("h1")).to have_text "Create a form"
    expect_page_to_have_no_axe_errors(page)
  end

  def when_i_click_share_a_preview
    click_link_or_button "Share a preview of your draft form"
  end

  def then_i_am_shown_the_share_a_preview_page
    expect(page.find("h1")).to have_text "Share a preview of your draft form"
    expect_page_to_have_no_axe_errors(page)
  end

  def when_i_click_the_copy_to_clipboard_button
    click_link_or_button "Copy link to clipboard"
  end

  def then_the_preview_url_is_copied_to_my_clipboard
    clipboard_text = get_clipboard_text
    expect(clipboard_text).to eq("runner-host/preview-draft/1/test-form")
  end

  def when_i_mark_the_task_complete
    choose "Yes"
    click_link_or_button "Save and continue"
  end

  def then_i_am_returned_to_the_form_page
    expect(page.find("h1")).to have_text "Create a form"
  end

  def then_i_see_a_success_message
    expect(page).to have_css ".govuk-notification-banner--success", text: "The preview task has been completed"
  end

  def get_clipboard_text
    cdp_params = {
      origin: page.server_url,
      permission: { name: "clipboard-read" },
      setting: "granted",
    }
    page.driver.browser.execute_cdp("Browser.setPermission", **cdp_params)

    page.evaluate_async_script("navigator.clipboard.readText().then(arguments[0])")
  end
end
