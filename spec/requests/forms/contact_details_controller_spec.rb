require "rails_helper"

RSpec.describe Forms::ContactDetailsController, type: :request do
  let(:current_user) { standard_user }

  let(:group) { create(:group, organisation: standard_user.organisation) }

  before do
    Membership.create!(group_id: group.id, user: current_user, added_by: current_user)
    GroupForm.create!(form_id: form.id, group_id: group.id)
    login_as_standard_user
  end

  describe "#new" do
    let(:form) { create :form, :with_support }

    before do
      get contact_details_path(form_id: form.id)
    end

    context "when the does not have any contact details set" do
      it "returns 200" do
        expect(response).to have_http_status(:ok)
      end

      it "renders new" do
        expect(response).to render_template(:new)
      end
    end
  end

  describe "#create" do
    let(:form) do
      create :form
    end

    context "when given valid params" do
      let(:params) { { forms_contact_details_input: { contact_details_supplied: ["", "supply_email"], email: "test@test.gov.uk", form: } } }

      it "updates the form" do
        expect {
          post(contact_details_create_path(form_id: form.id), params:)
        }.to change { form.reload.support_email }.to("test@test.gov.uk")
      end

      it "redirects to the confirmation page" do
        post(contact_details_create_path(form_id: form.id), params:)
        expect(response).to redirect_to(form_path(form_id: form.id))
      end
    end

    context "when given invalid parameters" do
      let(:params) { { forms_contact_details_input: { contact_details_supplied: ["", "supply_email"], email: "", form: } } }

      it "does not update the form" do
        expect {
          post(contact_details_create_path(form_id: form.id), params:)
        }.not_to(change { form.reload.support_email })
      end

      it "shows the error state" do
        post(contact_details_create_path(form_id: form.id), params:)
        expect(response).to render_template(:new)
        expect(response.body).to include I18n.t("error_summary.heading")
      end
    end

    context "when given an email address for a non-government inbox" do
      let(:params) { { forms_contact_details_input: { contact_details_supplied: ["", "supply_email"], email: "a@gmail.com", form: } } }

      it "does not update the form" do
        expect {
          post(contact_details_create_path(form_id: form.id), params:)
        }.not_to(change { form.reload.support_email })
      end

      it "shows the error state" do
        post(contact_details_create_path(form_id: form.id), params:)
        expect(response).to render_template(:new)
        expect(response.body).to include I18n.t("error_summary.heading")
        expect(response.body).to include I18n.t("errors.messages.non_government_email")
        expect(response).to have_http_status :unprocessable_content
      end
    end

    context "when current user has a government email address not ending with .gov.uk" do
      let(:current_user) do
        standard_user.update!(email: "user@public-sector-org.example")
        standard_user
      end

      let(:params) { { forms_contact_details_input: { contact_details_supplied: ["", "supply_email"], email: "a@public-sector-org.example", form: } } }

      it "updates the form" do
        expect {
          post(contact_details_create_path(form_id: form.id), params:)
        }.to change { form.reload.support_email }.to("a@public-sector-org.example")
      end

      it "redirects to the confirmation page" do
        post(contact_details_create_path(form_id: form.id), params:)
        expect(response).to redirect_to(form_path(form_id: form.id))
      end
    end
  end
end
