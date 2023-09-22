require "rails_helper"

describe "Request an upgrade from trial user to editor", type: :feature do
  it "A trial user can request an upgrade when they declare they meet the requirements" do
    login_as trial_user
    visit_upgrade_page
    check I18n.t("helpers.label.user_upgrade_request.met_requirements_options.1")
    submit_request
    then_i_can_see_request_sent_banner
  end

  it "A trial user cannot request an upgrade when they do not declare they meet the requirements" do
    login_as trial_user
    visit_upgrade_page
    submit_request
    then_i_see_an_error
  end

private

  def visit_upgrade_page
    visit new_user_upgrade_request_path
    expect(page).to have_text I18n.t("page_titles.user_upgrade_request_new")
  end

  def submit_request
    click_button I18n.t("continue")
  end

  def then_i_can_see_request_sent_banner
    expect(page).to have_text I18n.t("user_upgrade_request.show.panel_title")
  end

  def then_i_see_an_error
    expect(page).to have_text I18n.t("activemodel.errors.models.user_upgrade_request.attributes.met_requirements.accepted")
  end
end
