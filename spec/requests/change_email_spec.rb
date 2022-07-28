require "rails_helper"

RSpec.describe "ChangeEmail controller", type: :request do
  let(:form_response_data) do
    {
      id: 2,
      name: "Form name",
      submission_email: "submission@email.com",
      start_page: 1,
      org: "test-org",
    }.to_json
  end

  let(:form) do
    Form.new(
      name: "Form name",
      submission_email: "submission@email.com",
      id: 2,
      org: "test-org",
    )
  end

  let(:updated_form) do
    Form.new({
      id: 2,
      name: "Form name",
      submission_email: "new_submission@email.com",
      org: "test-org",
    })
  end

  before do
    ActiveResourceMock.mock_resource(form,
                                     {
                                       read: { response: form, status: 200 },
                                       update: { response: updated_form, status: 200 },
                                     })
  end

  describe "#new" do
    before do
      get change_form_email_path(id: 2)
    end

    it "Reads the form from the API" do
      expect(form).to have_been_read
    end
  end

  describe "#create" do
    before do
      post change_form_email_path(id: 2), params: { forms_change_email_form: { submission_email: "new_submission@email.com" } }
    end

    it "Reads the form from the API" do
      expect(form).to have_been_read
    end

    it "Updates the form on the API" do
      expect(updated_form).to have_been_updated
    end

    it "Redirects you to the form overview page" do
      expect(response).to redirect_to(form_path(2))
    end
  end
end
