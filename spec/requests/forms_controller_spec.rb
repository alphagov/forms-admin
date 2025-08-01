require "rails_helper"

RSpec.describe FormsController, type: :request do
  let(:form) { build(:form, id: 2) }
  let(:group) { create(:group, organisation: standard_user.organisation) }
  let(:user) { standard_user }

  before do
    Membership.create!(group_id: group.id, user: standard_user, added_by: standard_user)
    GroupForm.create!(form_id: form.id, group_id: group.id)

    login_as user
  end

  describe "Showing an existing form" do
    describe "Given a live form" do
      let(:form) { build(:form, :live, id: 2) }
      let(:params) { {} }

      before do
        allow(FormRepository).to receive_messages(find: form, pages: form.pages)

        get form_path(2, params)
      end

      it "renders the show template" do
        expect(response).to render_template("forms/show")
      end

      it "includes a task list" do
        expect(assigns[:task_list]).to be_truthy
      end
    end

    context "with a non-live form" do
      before do
        allow(FormRepository).to receive_messages(find: form, pages: form.pages)

        get form_path(2)
      end

      it "renders the show template" do
        expect(response).to render_template("forms/show")
      end
    end

    context "when user is not in same group as form" do
      let(:user) { build :user }

      before do
        allow(FormRepository).to receive(:find).and_return(form)

        get form_path(2)
      end

      it "Renders the forbidden page" do
        expect(response).to render_template("errors/forbidden")
      end

      it "Returns a 403 status" do
        expect(response.status).to eq(403)
      end
    end
  end

  describe "no form found" do
    let(:no_data_found_response) do
      {
        "error": "not_found",
      }
    end

    # TODO: Refactor this when we move from API to ActiveRecord
    before do
      ActiveResource::HttpMock.respond_to do |mock|
        mock.get "/api/v1/forms/999", headers, no_data_found_response, 404
      end

      get form_path(999)
    end

    it "Render the not found page" do
      expect(response.body).to include(I18n.t("not_found.title"))
    end

    it "returns 404" do
      expect(response.status).to eq(404)
    end
  end

  describe "#mark_pages_section_completed" do
    let(:pages) do
      [build(:page, page_id: 99)]
    end

    let(:form) do
      build(:form, id: 2, pages:, question_section_completed: "false")
    end

    let(:user) do
      standard_user
    end

    before do
      allow(FormRepository).to receive_messages(find: form, pages:, save!: form)

      login_as user

      post form_pages_path(2), params: { forms_mark_pages_section_complete_input: { mark_complete: "true" } }
    end

    it "Redirects you to the form overview page" do
      expect(response).to redirect_to(form_path(2))
    end

    context "when the mark completed form is invalid" do
      before do
        allow(FormRepository).to receive_messages(find: form, save!: nil)

        post form_pages_path(2), params: { forms_mark_pages_section_complete_input: { mark_complete: nil } }
      end

      it "renders the index page" do
        expect(response).to render_template("pages/index")
      end

      it "returns 422 error code" do
        expect(response.status).to eq(422)
      end

      it "sets mark_complete to false" do
        expect(assigns[:mark_complete_input].mark_complete).to eq("false")
      end
    end
  end
end
