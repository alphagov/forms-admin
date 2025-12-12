require "rails_helper"

RSpec.describe Pages::QuestionsController, type: :request do
  let(:form) { create :form }
  let(:draft_question) { create :draft_question_for_new_page, user: standard_user, form_id: form.id }
  let(:page) { create(:page, form_id: form.id) }
  let(:pages) do
    [page]
  end

  let(:group) { create(:group, organisation: standard_user.organisation) }

  let(:output) { StringIO.new }
  let(:logger) { ActiveSupport::Logger.new(output) }

  before do
    Membership.create!(group_id: group.id, user: standard_user, added_by: standard_user)
    GroupForm.create!(form_id: form.id, group_id: group.id)
    login_as_standard_user

    # Intercept the request logs so we can do assertions on them
    allow(Lograge).to receive(:logger).and_return(logger)
  end

  shared_examples "logging", :capture_logging do
    it "logs the answer type from the draft question" do
      expect(log_line["answer_type"]).to eq(draft_question.answer_type)
    end
  end

  describe "#new" do
    let(:draft_question) do
      record = create :draft_question_for_new_page, user: standard_user, form_id: form.id
      record.question_text = nil
      record.save!(validate: false)
      record.reload
    end

    before do
      draft_question

      get new_question_path(form_id: form.id)
    end

    it "returns 200" do
      expect(response).to have_http_status(:ok)
    end

    context "when the draft question is not present" do
      let(:draft_question) { nil }

      it "renders the index page" do
        expect(response).to render_template("errors/missing_draft_question")
      end

      it "returns a 422 error code" do
        expect(response.status).to eq(422)
      end
    end

    include_examples "logging"
  end

  describe "#create" do
    let(:params) do
      { pages_question_input: {
        question_text: "What is your home address?",
        hint_text: "This should be the location stated in your contract.",
        is_optional: false,
        is_repeatable: false,
      } }
    end

    before do
      # Setup a draft_question so that create question action doesn't need to create a completely new records
      draft_question
    end

    describe "Given a valid page" do
      it "creates a page" do
        expect {
          post(create_question_path(form.id), params:)
        }.to change(Page, :count).by(1)
      end

      it "Redirects you to edit page for new question" do
        post(create_question_path(form.id), params:)
        expect(response).to redirect_to(edit_question_path(form_id: form.id, page_id: Page.last.id))
      end

      it "displays a notification banner with call to action links" do
        post(create_question_path(form.id), params:)
        follow_redirect!
        results = Capybara.string(response.body)
        banner_contents = results.find(".govuk-notification-banner .govuk-notification-banner__content")

        expect(banner_contents).to have_link(text: "Add a question", href: start_new_question_path(form_id: form.id))
        expect(banner_contents).to have_link(text: "Back to your questions", href: form_pages_path(form_id: form.id))
      end

      describe "logging" do
        before do
          post(create_question_path(form.id), params:)
        end

        include_examples "logging"
      end
    end

    context "when question_input has invalid data" do
      let(:params) do
        { pages_question_input: {
          hint_text: "This should be the location stated in your contract.",
          is_optional: false,
        } }
      end

      before do
        post(create_question_path(form.id), params:)
      end

      it "returns 422" do
        expect(response).to have_http_status(:unprocessable_content)
      end

      it "renders new template" do
        expect(response).to have_rendered(:new)
      end

      it "outputs error message" do
        expect(response.body).to include("Enter a question")
      end
    end

    context "when the draft question is not present" do
      let(:draft_question) { nil }

      before do
        post(create_question_path(form.id), params:)
      end

      it "renders the index page" do
        expect(response).to render_template("errors/missing_draft_question")
      end

      it "returns a 422 error code" do
        expect(response.status).to eq(422)
      end
    end
  end

  describe "#edit" do
    describe "Given a page" do
      let(:page) { create :page, id: 99_999_999, form_id: form.id }

      before do
        # Setup a draft_question so that edit question action doesn't need to create a completely new records
        draft_question

        get edit_question_path(form_id: form.id, page_id: page.id)
      end

      it "creates a draft question in the database" do
        expect(DraftQuestion.last).to have_attributes(
          question_text: page.question_text,
          is_optional: page.is_optional,
          answer_type: page.answer_type,
        )
      end

      it "does not use the page id when assigning attributes to the draft question" do
        expect(DraftQuestion.last.id).not_to eq(page.id)
      end
    end
  end

  describe "#update" do
    let(:draft_question) do
      create(:address_draft_question, :with_guidance, page_id: page.id, user: standard_user, form_id: form.id)
    end

    let(:page) do
      create(
        :page,
        form_id: form.id,
        question_text: "Old question text",
        hint_text: "Old hint text",
        answer_type: "email",
        answer_settings: nil,
        is_optional: false,
        is_repeatable: false,
      )
    end

    describe "Given a page" do
      let(:params) do
        { pages_question_input: {
          form_id: form.id,
          question_text: "What is your home address?",
          hint_text: "This should be the location stated in your contract.",
          is_optional: "true",
          is_repeatable: "true",
        } }
      end

      before do
        draft_question
        post update_question_path(form_id: form.id, page_id: page.id), params:
      end

      it "Updates the page" do
        expect(page.reload).to have_attributes(
          question_text: "What is your home address?",
          hint_text: "This should be the location stated in your contract.",
          is_optional: true,
          is_repeatable: true,
          answer_type: "address",
          answer_settings: DataStruct.recursive_new(draft_question.answer_settings),
          page_heading: draft_question.page_heading,
          guidance_markdown: draft_question.guidance_markdown,
        )
      end

      it "Redirects you to edit page for question that was updated" do
        expect(response).to redirect_to(edit_question_path(form_id: form.id, page_id: page.id))
      end

      it "displays a notification banner with call to action links" do
        follow_redirect!
        results = Capybara.string(response.body)
        banner_contents = results.find(".govuk-notification-banner .govuk-notification-banner__content")

        expect(banner_contents).to have_link(text: "Add a question", href: start_new_question_path(form_id: form.id))
        expect(banner_contents).to have_link(text: "Back to your questions", href: form_pages_path(form_id: form.id))
      end

      it "logs the answer type from the page", :capture_logging do
        expect(log_line["answer_type"]).to eq(page.reload.answer_type)
      end

      context "when question being updated has a question after it" do
        let!(:next_page) { create(:page, form_id: form.id) }

        let(:params) do
          { pages_question_input: {
            page_id: page.id,
            form_id: form.id,
            question_text: "What is your home address?",
            hint_text: "This should be the location stated in your contract.",
            answer_type: "address",
            is_optional: "false",
            is_repeatable: "false",
            page_heading: "New page heading",
            guidance_markdown: "## Heading level 2",
          } }
        end

        it "Redirects you to edit page for new question" do
          expect(response).to redirect_to(edit_question_path(form_id: form.id, page_id: page.id))
        end

        it "displays a notification banner with call to action links" do
          follow_redirect!
          results = Capybara.string(response.body)
          banner_contents = results.find(".govuk-notification-banner .govuk-notification-banner__content")

          expect(banner_contents).to have_link(text: "Edit next question", href: edit_question_path(form_id: form.id, page_id: next_page.id))
          expect(banner_contents).to have_link(text: "Back to your questions", href: form_pages_path(form_id: form.id))
        end
      end
    end

    context "when question_input has invalid data" do
      before do
        post update_question_path(form_id: form.id, page_id: page.id), params: { pages_question_input: {
          form_id: form.id,
          question_text: nil,
          hint_text: "This should be the location stated in your contract.",
          answer_type: "address",
          page_heading: "New page heading",
          guidance_markdown: "## Heading level 2",
        } }
      end

      it "returns 422" do
        expect(response).to have_http_status(:unprocessable_content)
      end

      it "renders edit template" do
        expect(response).to have_rendered(:edit)
      end

      it "outputs error message" do
        expect(response.body).to include("Enter a question")
      end
    end
  end
end
