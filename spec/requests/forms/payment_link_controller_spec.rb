require "rails_helper"

RSpec.describe Forms::PaymentLinkController, type: :request do
  let(:form) do
    build(:form, :live, id: 2, payment_url: "https://www.example.com")
  end

  let(:updated_form) do
    new_form = form
    new_form.payment_url = "https://www.gov.uk/payments/organisation/service"
    new_form
  end

  let(:group) { create(:group, organisation: standard_user.organisation) }

  before do
    ActiveResource::HttpMock.respond_to do |mock|
      mock.get "/api/v1/forms/2", headers, form.to_json, 200
      mock.put "/api/v1/forms/2", headers
    end

    ActiveResourceMock.mock_resource(form,
                                     {
                                       read: { response: form, status: 200 },
                                       update: { response: updated_form, status: 200 },
                                     })

    Membership.create!(group_id: group.id, user: standard_user, added_by: standard_user)
    GroupForm.create!(form_id: form.id, group_id: group.id)

    login_as_standard_user
  end

  describe "#new" do
    before do
      ActiveResource::HttpMock.respond_to do |mock|
        mock.put "/api/v1/forms/2", post_headers
        mock.get "/api/v1/forms/2", headers, form.to_json, 200
      end
      get payment_link_path(form_id: 2)
    end

    it "Reads the form from the API" do
      expect(form).to have_been_read
    end
  end

  describe "#create" do
    before do
      ActiveResource::HttpMock.respond_to do |mock|
        mock.get "/api/v1/forms/2", headers, form.to_json, 200
        mock.put "/api/v1/forms/2", post_headers
      end
      post payment_link_path(form_id: 2), params: { forms_payment_link_input: { payment_url: "https://www.gov.uk/payments/organisation/service" } }
    end

    it "Reads the form from the API" do
      expect(form).to have_been_read
    end

    it "Updates the form on the API" do
      expect(form).to have_been_updated_to(updated_form)
    end

    it "Redirects you to the form overview page" do
      expect(response).to redirect_to(form_path(2))
    end
  end
end
