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

  describe "Editing an existing form" do
    describe "Given a form" do
      let(:form) do
        Form.new(
          {
            id: 2,
            name: "Form name",
            submission_email: "submission@email.com",
          },
        )
      end

      before do
        ActiveResourceMock.mock_resource(form, { read: { response: form } })
        get edit_form_path(2)
      end

      it "Reads the form from the API" do
        expect(form).to have_been_read
      end
    end
  end

  describe "Updating an existing form" do
    describe "Given a form" do
      let(:form) do
        Form.new(
          name: "Form name",
          submission_email: "submission@email.com",
          id: 2,
        )
      end

      let(:updated_form_data) do
        {
          id: 2,
          name: "Updated name",
          submission_email: "submission@email.com",
          org: "test-org",
        }
      end

      let(:updated_form) do
        Form.new(updated_form_data)
      end

      before do
        ActiveResourceMock.mock_resource(form,
                                         {
                                           read: { response: form, status: 200 },
                                           update: { response: updated_form, status: 200 },
                                         })

        patch form_path(id: 2), params: { form: updated_form_data }
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

  describe "Creating a new form" do
    describe "Given a valid form" do
      let(:form_data) do
        {
          name: "Form name",
          submission_email: "submission@email.com",
          org: "test-org",
        }
      end

      before do
        ActiveResource::HttpMock.respond_to do |mock|
          mock.post "/api/v1/forms", {}, { id: 2 }.to_json, 200
        end

        post "/forms", params: form_data
      end

      it "Redirects you to the form overview page" do
        expect(response).to redirect_to(form_path(2))
      end

      it "Creates the form on the API" do
        form = Form.new(form_data)
        expect(form).to have_been_created
      end
    end
  end

  describe "Deleting an existing form" do
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

        delete form_path(id: 2)
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
