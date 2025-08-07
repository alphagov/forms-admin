require "rails_helper"

feature "Move a form", type: :feature do
  describe "moving a form to another group" do
    let(:group) { create(:group, organisation: organisation_admin_user.organisation) }
    let(:form) { create(:form_record) }

    scenario "organisation admin can move a form to another group" do
      given_i_am_logged_in_as_an_organisation_admin
    end
  end
end
