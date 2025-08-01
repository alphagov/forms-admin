require "rails_helper"

RSpec.describe Pages::QuestionsController, type: :request do
  let(:form) { build :form, id: 2, pages: }

  let(:draft_question) { create :draft_question_for_new_page, user: standard_user, form_id: 2 }

  let(:page) do
    build(:page,
          id: 1,
          form_id: 2,
          question_text: draft_question.question_text,
          hint_text: draft_question.hint_text,
          answer_type: draft_question.answer_type,
          answer_settings: nil,
          is_optional: false,
          is_repeatable: false,
          page_heading: nil,
          guidance_markdown: nil)
  end

  let(:pages) do
    [page]
  end

  let(:group) { create(:group, organisation: standard_user.organisation) }

  let(:output) { StringIO.new }
  let(:logger) { ActiveSupport::Logger.new(output) }

  before do
    allow(FormRepository).to receive_messages(find: form, pages:)
    allow(PageRepository).to receive_messages(create!: page, find: page)

    Membership.create!(group_id: group.id, user: standard_user, added_by: standard_user)
    GroupForm.create!(form_id: form.id, group_id: group.id)
    login_as_standard_user

    # Intercept the request logs so we can do assertions on them
    allow(Lograge).to receive(:logger).and_return(logger)
  end

  shared_examples "logging" do
    it "logs the answer type from the draft question" do
      expect(log_lines(output)[0]["answer_type"]).to eq(draft_question.answer_type)
    end
  end

  describe "#new" do
    let(:draft_question) do
      record = create :draft_question_for_new_page, user: standard_user, form_id: 2
      record.question_text = nil
      record.save!(validate: false)
      record.reload
    end

    before do
      draft_question

      get new_question_path(form_id: 2)
    end

    it "Reads the form" do
      expect(FormRepository).to have_received(:find)
    end

    it "returns 200" do
      expect(response).to have_http_status(:ok)
    end

    include_examples "logging"
  end

  describe "#create" do
    describe "Given a valid page" do
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

        post create_question_path(2), params:
      end

      it "Redirects you to edit page for new question" do
        expect(response).to redirect_to(edit_question_path(form_id: 2, page_id: 1))
      end

      it "displays a notification banner with call to action links" do
        follow_redirect!
        results = Capybara.string(response.body)
        banner_contents = results.find(".govuk-notification-banner .govuk-notification-banner__content")

        expect(banner_contents).to have_link(text: "Add a question", href: start_new_question_path(form_id: 2))
        expect(banner_contents).to have_link(text: "Back to your questions", href: form_pages_path(form_id: 2))
      end

      include_examples "logging"
    end

    context "when question_input has invalid data" do
      before do
        # Setup a draft_question so that create question action doesn't need to create a completely new records
        draft_question

        post create_question_path(2), params: { pages_question_input: {
          hint_text: "This should be the location stated in your contract.",
          is_optional: false,
        } }
      end

      it "returns 422" do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "renders new template" do
        expect(response).to have_rendered(:new)
      end

      it "outputs error message" do
        expect(response.body).to include("Enter a question")
      end
    end
  end

  describe "#edit" do
    describe "Given a page" do
      before do
        # Setup a draft_question so that edit question action doesn't need to create a completely new records
        draft_question

        get edit_question_path(form_id: 2, page_id: 1)
      end

      it "Reads the page from the page repository" do
        expect(PageRepository).to have_received(:find)
      end

      context "when page has unrecognised attributes" do
        let(:page) do
          build(:page,
                id: 1,
                form_id: 2,
                question_text: draft_question.question_text,
                hint_text: draft_question.hint_text,
                answer_type: draft_question.answer_type,
                answer_settings: nil,
                is_optional: false,
                page_heading: nil,
                guidance_markdown: nil,
                newly_added_to_api: "some value")
        end

        it "renders successfully" do
          expect(response).to have_http_status(:ok)
        end

        include_examples "logging"
      end
    end
  end

  describe "#update" do
    let(:draft_question) do
      record = create :draft_question, user: standard_user, form_id: 2
      record.question_text = nil
      record.save!(validate: false)
      record.reload
    end

    let(:page) do
      build(
        :page,
        id: 1,
        form_id: 2,
        question_text: "What is your work address?",
        hint_text: "This should be the location stated in your contract.",
        answer_type: "address",
        answer_settings: nil,
        is_optional: false,
        is_repeatable: false,
        page_heading: "New page heading",
        guidance_markdown: "## Heading level 2",
      )
    end

    describe "Given a page" do
      let(:params) do
        { pages_question_input: {
          form_id: 2,
          question_text: "What is your home address?",
          hint_text: "This should be the location stated in your contract.",
          answer_type: "address",
          is_optional: "false",
          is_repeatable: "false",
          page_heading: "New page heading",
          guidance_markdown: "## Heading level 2",
        } }
      end

      before do
        allow(PageRepository).to receive_messages(find: page, save!: page)

        post update_question_path(form_id: 2, page_id: 1), params:
      end

      it "Reads the page from the PageRepository" do
        expect(PageRepository).to have_received(:find)
      end

      it "Updates the page through the page repository" do
        expect(PageRepository).to have_received(:save!)
      end

      it "Redirects you to edit page for question that was updated" do
        expect(response).to redirect_to(edit_question_path(form_id: 2, page_id: 1))
      end

      it "displays a notification banner with call to action links" do
        follow_redirect!
        results = Capybara.string(response.body)
        banner_contents = results.find(".govuk-notification-banner .govuk-notification-banner__content")

        expect(banner_contents).to have_link(text: "Add a question", href: start_new_question_path(form_id: 2))
        expect(banner_contents).to have_link(text: "Back to your questions", href: form_pages_path(form_id: 2))
      end

      it "logs the answer type from the page" do
        expect(log_lines(output)[0]["answer_type"]).to eq(page.answer_type)
      end

      context "when question being updated has a question after it" do
        let(:pages) { [page, build(:page, id: 4)] }

        let(:params) do
          { pages_question_input: {
            page_id: 1,
            form_id: 2,
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
          expect(response).to redirect_to(edit_question_path(form_id: 2, page_id: 1))
        end

        it "displays a notification banner with call to action links" do
          follow_redirect!
          results = Capybara.string(response.body)
          banner_contents = results.find(".govuk-notification-banner .govuk-notification-banner__content")

          expect(banner_contents).to have_link(text: "Edit next question", href: edit_question_path(form_id: 2, page_id: 4))
          expect(banner_contents).to have_link(text: "Back to your questions", href: form_pages_path(form_id: 2))
        end
      end
    end

    context "when question_input has invalid data" do
      before do
        post update_question_path(form_id: 2, page_id: 1), params: { pages_question_input: {
          form_id: 2,
          question_text: nil,
          hint_text: "This should be the location stated in your contract.",
          answer_type: "address",
          page_heading: "New page heading",
          guidance_markdown: "## Heading level 2",
        } }
      end

      it "returns 422" do
        expect(response).to have_http_status(:unprocessable_entity)
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
