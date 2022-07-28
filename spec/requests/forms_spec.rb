require "rails_helper"

RSpec.describe "Forms", type: :request do
  describe "Showing an existing form" do
    describe "Given a form" do
      let(:form) do
        Form.new({
          id: 2,
          name: "Form name",
          submission_email: "submission@email.com",
        })
      end

      let(:pages) do
        [Page.new({
          id: 1,
          form_id: 2,
          question_text: "What is your work address?",
          question_short_name: "Work address",
          hint_text: "This should be the location stated in your contract.",
          answer_type: "address",
        })]
      end

      before do
        ActiveResource::HttpMock.respond_to do |mock|
          mock.get "/api/v1/forms/2", {}, form.to_json, 200
          mock.get "/api/v1/forms/2/pages", {}, pages.to_json, 200
        end

        get form_path(2)
      end

      it "Reads the form from the API" do
        expect(form).to have_been_read

        pages_request = ActiveResource::Request.new(:get, "/api/v1/forms/2")
        expect(ActiveResource::HttpMock.requests).to include pages_request
      end
    end
  end

  describe "Deleting an existing form" do
    describe "Given a valid form" do
      let(:form) do
        Form.new({
          name: "Form name",
          submission_email: "submission@email.com",
          id: 2,
          org: "test-org",
          start_page: 1,
        })
      end

      before do
        ActiveResource::HttpMock.respond_to do |mock|
          mock.get "/api/v1/forms/2", {}, form.to_json, 200
        end

        get delete_form_path(form_id: 2)
      end

      it "reads the form from the API" do
        expect(form).to have_been_read
      end
    end
  end

  describe "Destroying an existing form" do
    describe "Given a valid form" do
      let(:form) do
        Form.new(
          name: "Form name",
          submission_email: "submission@email.com",
          id: 2,
        )
      end

      before do
        ActiveResourceMock.mock_resource(form,
                                         {
                                           read: { response: form, status: 200 },
                                           delete: { response: {}, status: 200 },
                                         })

        delete destroy_form_path(form_id: 2, forms_delete_confirmation_form: { confirm_deletion: "true" })
      end

      it "Redirects you to the home screen" do
        expect(response).to redirect_to(root_path)
      end

      it "Deletes the form on the API" do
        expect(form).to have_been_deleted
      end
    end
  end
end
