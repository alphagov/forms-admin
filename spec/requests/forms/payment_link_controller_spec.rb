require "rails_helper"

RSpec.describe Forms::PaymentLinkController, type: :request do
  let(:form) { create(:form, :live, payment_url: "https://www.example.com") }
  let(:payment_url) { "https://www.gov.uk/payments/organisation/service" }

  let(:group) { create(:group, organisation: standard_user.organisation) }

  before do
    Membership.create!(group_id: group.id, user: standard_user, added_by: standard_user)
    GroupForm.create!(form_id: form.id, group_id: group.id)

    login_as_standard_user
  end

  describe "#create" do
    let(:params) { { forms_payment_link_input: { payment_url: } } }

    context "when the payment link is changed" do
      it "Updates the form" do
        expect {
          post(payment_link_path(form_id: form.id), params:)
        }.to change { form.reload.payment_url }.to(payment_url)
      end

      it "Redirects you to the form overview page" do
        post(payment_link_path(form_id: form.id), params:)
        expect(response).to redirect_to(form_path(form.id))
      end

      it "displays a flash message that the payment link has been saved" do
        post(payment_link_path(form_id: form.id), params:)
        expect(flash[:success]).to eq(I18n.t("banner.success.form.payment_link_saved"))
      end
    end

    context "when a payment link is added" do
      let(:form) { create(:form, :live, payment_url: nil) }

      before do
        post(payment_link_path(form_id: form.id), params:)
      end

      it "displays a flash message that the payment link has been saved" do
        expect(flash[:success]).to eq(I18n.t("banner.success.form.payment_link_saved"))
      end
    end

    context "when a payment link is removed" do
      let(:payment_url) { "" }

      before do
        post(payment_link_path(form_id: form.id), params:)
      end

      it "displays a flash message that the payment link has been removed" do
        expect(flash[:success]).to eq(I18n.t("banner.success.form.payment_link_removed"))
      end
    end

    context "when the payment link is unchanged" do
      let(:form) { create(:form, :live, payment_url:) }

      before do
        post(payment_link_path(form_id: form.id), params:)
      end

      it "does not display a flash message" do
        expect(flash[:success]).to be_nil
      end
    end

    context "when the payment link was not previously set and no payment link is entered" do
      let(:form) { create(:form, :live, payment_url: nil) }
      let(:payment_url) { "" }

      before do
        post(payment_link_path(form_id: form.id), params:)
      end

      it "does not display a flash message" do
        expect(flash[:success]).to be_nil
      end
    end
  end
end
