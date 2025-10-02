require "rails_helper"

RSpec.describe Forms::PaymentLinkController, type: :request do
  let(:form) { create(:form, :live, payment_url: "https://www.example.com") }
  let(:payment_url) { "https://www.gov.uk/payments/organisation/service" }

  let(:updated_form) { build(:form, :live, id: form.id, payment_url:) }

  let(:group) { create(:group, organisation: standard_user.organisation) }

  before do
    allow(FormRepository).to receive_messages(save!: updated_form)

    Membership.create!(group_id: group.id, user: standard_user, added_by: standard_user)
    GroupForm.create!(form_id: form.id, group_id: group.id)

    login_as_standard_user
  end

  describe "#create" do
    context "when the payment link is changed" do
      before do
        post payment_link_path(form_id: form.id), params: { forms_payment_link_input: { payment_url: } }
      end

      it "Updates the form" do
        expect(FormRepository).to have_received(:save!)
      end

      it "Redirects you to the form overview page" do
        expect(response).to redirect_to(form_path(form.id))
      end

      it "displays a flash message that the payment link has been saved" do
        expect(flash[:success]).to eq(I18n.t("banner.success.form.payment_link_saved"))
      end
    end

    context "when a payment link is added" do
      let(:form) { create(:form, :live, payment_url: nil) }

      before do
        post payment_link_path(form_id: form.id), params: { forms_payment_link_input: { payment_url: } }
      end

      it "displays a flash message that the payment link has been saved" do
        expect(flash[:success]).to eq(I18n.t("banner.success.form.payment_link_saved"))
      end
    end

    context "when a payment link is removed" do
      before do
        post payment_link_path(form_id: form.id), params: { forms_payment_link_input: { payment_url: "" } }
      end

      it "displays a flash message that the payment link has been removed" do
        expect(flash[:success]).to eq(I18n.t("banner.success.form.payment_link_removed"))
      end
    end

    context "when the payment link is unchanged" do
      let(:form) { create(:form, :live, payment_url:) }

      before do
        post payment_link_path(form_id: form.id), params: { forms_payment_link_input: { payment_url: payment_url } }
      end

      it "does not display a flash message" do
        expect(flash[:success]).to be_nil
      end
    end

    context "when the payment link was not previously set and no payment link is entered" do
      let(:form) { create(:form, :live, payment_url: nil) }

      before do
        post payment_link_path(form_id: form.id), params: { forms_payment_link_input: { payment_url: "" } }
      end

      it "does not display a flash message" do
        expect(flash[:success]).to be_nil
      end
    end
  end
end
