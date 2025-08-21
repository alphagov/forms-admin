require "rails_helper"

RSpec.describe Pages::TypeOfAnswerController, type: :request do
  let(:form) { create :form }
  let(:pages) { build_list :page, 5, form_id: form.id }
  let(:page) { pages.first }
  let(:type_of_answer_input) { build :type_of_answer_input }

  let(:group) { create(:group, organisation: standard_user.organisation) }

  let(:output) { StringIO.new }
  let(:logger) { ActiveSupport::Logger.new(output) }

  before do
    allow(FormRepository).to receive_messages(find: form, pages: pages)
    allow(PageRepository).to receive_messages(find: page, save!: page)

    Membership.create!(group_id: group.id, user: standard_user, added_by: standard_user)
    GroupForm.create!(form_id: form.id, group_id: group.id)
    login_as_standard_user

    # Intercept the request logs so we can do assertions on them
    allow(Lograge).to receive(:logger).and_return(logger)
  end

  describe "#new" do
    before do
      get type_of_answer_new_path(form_id: form.id)
    end

    it "reads the existing form" do
      expect(FormRepository).to have_received(:find)
    end

    it "sets an instance variable for type_of_answer_path" do
      path = assigns(:type_of_answer_path)
      expect(path).to eq type_of_answer_new_path(form.id)
    end

    it "renders the template" do
      expect(response).to have_rendered(:type_of_answer)
    end

    it "shows the file answer type option" do
      expect(response.body).to include("File")
    end
  end

  describe "#create" do
    context "when form is valid and ready to store" do
      before do
        post type_of_answer_create_path form_id: form.id, params: { pages_type_of_answer_input: { answer_type: type_of_answer_input.answer_type } }
      end

      context "when answer type is not selection" do
        let(:type_of_answer_input) { build :type_of_answer_input, :with_simple_answer_type }

        it "saves the answer type & answer settings to draft question" do
          expect(type_of_answer_input.draft_question.answer_type).to eq(type_of_answer_input.answer_type)
          expect(type_of_answer_input.draft_question.answer_settings).to be_empty
        end

        it "redirects the user to the question details page" do
          expect(response).to redirect_to new_question_path(form.id)
        end

        it "logs the answer type" do
          expect(log_lines(output)[0]["answer_type"]).to eq(type_of_answer_input.answer_type)
        end
      end

      context "when answer type is selection" do
        let(:type_of_answer_input) { build :type_of_answer_input, answer_type: "selection" }

        it "saves the answer type & answer settings to draft question" do
          form = assigns(:type_of_answer_input)
          expect(form.draft_question.answer_type).to eq(type_of_answer_input.answer_type)
          expect(form.draft_question.answer_settings).to eq(selection_options: [{ name: "" },
                                                                                { name: "" }])
        end

        it "redirects the user to the question text page" do
          expect(response).to redirect_to question_text_new_path(form.id)
        end
      end

      context "when answer type is text" do
        let(:type_of_answer_input) { build :type_of_answer_input, answer_type: "text" }

        it "saves the answer type to draft question" do
          form = assigns(:type_of_answer_input)
          expect(form.draft_question.answer_type).to eq(type_of_answer_input.answer_type)
          expect(form.draft_question.answer_settings).to eq(input_type: nil)
        end

        it "redirects the user to the text settings page" do
          expect(response).to redirect_to text_settings_new_path(form.id)
        end
      end

      context "when answer type is date" do
        let(:type_of_answer_input) { build :type_of_answer_input, answer_type: "date" }

        it "saves the answer type to draft question" do
          form = assigns(:type_of_answer_input)
          expect(form.draft_question.answer_settings).to include(input_type: nil)
        end

        it "redirects the user to the date settings page" do
          expect(response).to redirect_to date_settings_new_path(form.id)
        end
      end

      context "when answer type is address" do
        let(:type_of_answer_input) { build :type_of_answer_input, answer_type: "address" }

        it "saves the answer type to draft question" do
          form = assigns(:type_of_answer_input)
          expect(form.draft_question.answer_type).to eq(type_of_answer_input.answer_type)
          expect(form.draft_question.answer_settings).to eq(input_type: nil)
        end

        it "redirects the user to the address settings page" do
          expect(response).to redirect_to address_settings_new_path(form.id)
        end
      end

      context "when answer type is name" do
        let(:type_of_answer_input) { build :type_of_answer_input, answer_type: "name" }

        it "saves the answer type to draft question" do
          form = assigns(:type_of_answer_input)
          expect(form.draft_question.answer_type).to eq(type_of_answer_input.answer_type)
          expect(form.draft_question.answer_settings).to eq(input_type: nil, title_needed: nil)
        end

        it "redirects the user to the name settings page" do
          expect(response).to redirect_to name_settings_new_path(form.id)
        end
      end
    end

    context "when form is invalid" do
      before do
        post type_of_answer_create_path form_id: form.id, params: { pages_type_of_answer_input: { answer_type: nil } }
      end

      it "renders the type of answer view if there are errors" do
        expect(response).to have_rendered(:type_of_answer)
      end
    end
  end

  describe "#edit" do
    let(:page) { build :page, :with_simple_answer_type, id: 2, form_id: form.id }

    before do
      allow(PageRepository).to receive(:find).with(page_id: "2", form_id: 1).and_return(page)

      get type_of_answer_edit_path(form_id: page.form_id, page_id: page.id)
    end

    it "reads the existing form" do
      expect(FormRepository).to have_received(:find)
    end

    it "returns the existing page answer type" do
      form = assigns(:type_of_answer_input)
      expect(form.answer_type).to eq page.answer_type
    end

    it "sets an instance variable for type_of_answer_path" do
      path = assigns(:type_of_answer_path)
      expect(path).to eq type_of_answer_edit_path(form.id)
    end

    it "renders the template" do
      expect(response).to have_rendered(:type_of_answer)
    end

    it "logs the answer type" do
      expect(log_lines(output)[0]["answer_type"]).to eq(page.answer_type)
    end

    it "shows the file answer type option" do
      expect(response.body).to include("File")
    end
  end

  describe "#update" do
    let(:page) { build :page, :with_simple_answer_type, id: 2, form_id: form.id, answer_type: "email" }

    before do
      allow(PageRepository).to receive(:find).with(page_id: "2", form_id: 1).and_return(page)
      allow(PageRepository).to receive(:save!).with(hash_including(page_id: "2", form_id: 1))
    end

    context "when form is valid and ready to update in the DB" do
      let(:answer_type) { "number" }
      let(:pages_type_of_answer_input) { { answer_type: } }

      before do
        post type_of_answer_update_path(form_id: page.form_id, page_id: page.id), params: { pages_type_of_answer_input: }
      end

      it "saves the updated answer type to draft_question" do
        form = assigns(:type_of_answer_input)
        expect(form.draft_question.answer_type).to eq answer_type
      end

      it "redirects the user to the question details page" do
        expect(response).to redirect_to edit_question_path(form.id, page.id)
      end

      it "logs the updated answer type" do
        expect(log_lines(output)[0]["answer_type"]).to eq(answer_type)
      end

      context "when answer type is selection" do
        let(:answer_type) { "selection" }

        it "saves the answer type to draft_question" do
          form = assigns(:type_of_answer_input)
          expect(form.draft_question.answer_type).to eq "selection"
        end

        it "redirects the user to the selection type page" do
          expect(response).to redirect_to selection_type_edit_path(form.id, page.id)
        end
      end
    end

    context "when form is invalid" do
      before do
        post type_of_answer_create_path form_id: form.id, params: { pages_type_of_answer_input: { answer_type: nil } }
      end

      it "renders the type of answer view if there are errors" do
        expect(response).to have_rendered(:type_of_answer)
      end
    end
  end
end
