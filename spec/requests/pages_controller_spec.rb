require "rails_helper"

RSpec.describe PagesController, type: :request do
  let(:form_response) { Api::V1::FormResource.new(attributes_for(:form, id: 2), true) }

  let(:group) { create(:group, organisation: standard_user.organisation) }
  let(:membership) { create :membership, group:, user: standard_user }

  let(:output) { StringIO.new }
  let(:logger) { ActiveSupport::Logger.new(output) }

  before do
    membership
    login_as_standard_user

    # Intercept the request logs so we can do assertions on them
    allow(Lograge).to receive(:logger).and_return(logger)
  end

  shared_examples "logging" do
    it "logs the answer type" do
      expect(log_lines(output)[0]["answer_type"]).to eq(page.answer_type)
    end
  end

  describe "#index" do
    let(:pages) do
      [build(:page, id: 99),
       build(:page, id: 100),
       build(:page, id: 101)]
    end
    let(:form) do
      build(:form, id: 2, pages:)
    end

    before do
      allow(FormRepository).to receive_messages(find: form, pages: pages)
    end

    context "with a form in a group that the user is a member of" do
      before do
        group.group_forms.create!(form_id: form.id)
        get form_pages_path(form.id)
      end

      it "returns a 200 status code" do
        expect(response).to have_http_status(:ok)
      end

      it "renders the pages#index template" do
        expect(response).to render_template("pages/index")
      end
    end

    context "with a form in a group that the user is not a member of" do
      let(:form) { build :form, id: 2 }
      let(:other_group) { create(:group) }

      before do
        other_group.group_forms.build(form_id: form.id)
        get form_pages_path(2)
      end

      it "Renders the forbidden page" do
        expect(response).to render_template("errors/forbidden")
      end

      it "Returns a 403 status" do
        expect(response.status).to eq(403)
      end
    end

    describe "when there are validation errors" do
      let(:routing_condition) { [(build :condition, :with_answer_value_missing, id: 1, routing_page_id: 99, check_page_id: 99, goto_page_id: 101)] }
      let(:collect_analytics) { true }

      before do
        allow(standard_user).to receive(:collect_analytics?).and_return(collect_analytics)

        pages.first.routing_conditions = routing_condition
        group.group_forms.create!(form_id: form.id)
        get form_pages_path(2)
      end

      context "when analytics is enabled" do
        it "sends the validation errors to analytics" do
          page = Capybara.string(response.body)
          expect(page).to have_css("[data-analytics-events]", text: /answer_value_doesnt_exist/, visible: :all)
        end
      end

      context "when analytics is not enabled" do
        let(:collect_analytics) { false }

        it "does not send the validation errors to analytics" do
          page = Capybara.string(response.body)
          expect(page).not_to have_css("[data-analytics-events]", text: /answer_value_doesnt_exist/, visible: :all)
        end
      end
    end
  end

  describe "#start_new_question" do
    let(:current_form) { build :form, id: 1 }
    let(:original_draft_question) { create :draft_question, form_id: 1, user: standard_user }

    before do
      allow(FormRepository).to receive(:find).and_return(current_form)

      GroupForm.create!(form_id: current_form.id, group_id: group.id)
    end

    it "clears draft questions data for current user and form" do
      original_draft_question # Setup initial draft question which will clear
      expect {
        get start_new_question_path(form_id: current_form.id)
      }.to change { DraftQuestion.exists?({ form_id: current_form.id, user: standard_user }) }.from(true).to(false)
    end

    it "does not clear draft questions data for a different form" do
      create :draft_question, form_id: 99, user: standard_user # Setup initial draft question which should not clear
      get start_new_question_path(form_id: current_form.id)
      expect(DraftQuestion.exists?({ form_id: 99, user: standard_user })).to be true
    end

    it "redirects to type_of_answer_create_path" do
      get start_new_question_path(form_id: current_form.id)
      expect(response).to redirect_to(type_of_answer_create_path(form_id: current_form.id))
    end
  end

  describe "#delete" do
    context "with a valid page" do
      let(:page) do
        build(
          :page,
          id: 1,
          form_id: 2,
          question_text: "What is your work address?",
          hint_text: "This should be the location stated in your contract.",
          answer_type: "address",
          is_optional: false,
        )
      end

      let(:pages) { [page] }

      before do
        allow(FormRepository).to receive_messages(find: form_response, pages: pages)

        pages.each do |page|
          allow(PageRepository).to receive(:find).with(page_id: page.id.to_s, form_id: 2).and_return(page)
          allow(PageRepository).to receive(:find).with(page_id: page.id, form_id: 2).and_return(page)
        end

        allow(PageRepository).to receive_messages(destroy: true)

        GroupForm.create!(form_id: 2, group_id: group.id)

        get delete_page_path(form_id: 2, page_id: page.id)
      end

      it "renders the delete page template" do
        expect(response).to render_template("pages/delete")
      end

      it "reads the form through the page repository" do
        expect(PageRepository).to have_received(:find)
      end

      include_examples "logging"

      context "when current user is not in group for form the page is in" do
        let(:membership) { nil }

        it "returns an error" do
          expect(response).to have_http_status :forbidden
        end
      end

      context "when page to delete has no routes" do
        it "does not render a warning" do
          expect(response.body).not_to include "Important"
        end
      end

      context "when page to delete is start of one or more routes" do
        let(:page) do
          build(
            :page,
            :with_selection_settings,
            id: 1,
            form_id: 2,
            question_text: "What is your favourite colour?",
            selection_options: [{ name: "Red" }, { name: "Green" }, { name: "Blue" }],
            only_one_option: true,
            routing_conditions: [
              build(:condition, routing_page_id: 1, check_page_id: 1, answer_value: "red", skip_to_end: true),
              build(:condition, routing_page_id: 1, check_page_id: 1, answer_value: "green", goto_page_id: 3),
            ],
          )
        end

        it "renders a warning about deleting this page" do
          assert_select(".govuk-notification-banner", count: 1) do
            assert_select "*", "Important"
            assert_select "h3", "Question #{page.position} is the start of a route"
            assert_select "p.govuk-body", /If you delete this question, its routes will also be deleted/
            assert_select "p.govuk-body a", "View question #{page.position}’s routes"
          end
        end
      end

      context "when page to delete is at the end of a route" do
        let(:pages) do
          [
            build(
              :page,
              :with_selection_settings,
              id: 1,
              form_id: 2,
              position: 1,
              question_text: "What is your favourite colour?",
              selection_options: [{ name: "Red" }, { name: "Green" }, { name: "Blue" }],
              only_one_option: true,
              routing_conditions: [
                build(:condition, routing_page_id: 1, check_page_id: 1, answer_value: "green", goto_page_id: 3),
              ],
            ),
            build(
              :page,
              id: 3,
              form_id: 2,
              position: 3,
            ),
          ]
        end

        let(:page) { pages.last }

        it "renders a warning about deleting this page" do
          assert_select(".govuk-notification-banner", count: 1) do
            assert_select "*", "Important"
            assert_select "h3", "Question 3 is at the end of a route"
            assert_select "p.govuk-body a", "Question 1’s route"
            assert_select "p.govuk-body", /Question 1’s route\s*goes to this question. If you delete this question, question 1’s routes will also be deleted./
          end
        end
      end

      context "when page to delete is start of a secondary skip route" do
        let(:pages) do
          [
            build(
              :page,
              :with_selection_settings,
              id: 1,
              form_id: 2,
              position: 1,
              question_text: "What is your favourite colour?",
              selection_options: [{ name: "Red" }, { name: "Green" }, { name: "Blue" }],
              only_one_option: true,
              routing_conditions: [
                build(:condition, routing_page_id: 1, check_page_id: 1, answer_value: "green", goto_page_id: 3),
              ],
            ),
            build(
              :page,
              id: 5,
              form_id: 2,
              position: 5,
              routing_conditions: [
                build(:condition, routing_page_id: 5, check_page_id: 1, answer_value: nil, goto_page_id: 8),
              ],
            ),
          ]
        end

        let(:page) { pages.last }

        it "renders a warning about deleting this page" do
          assert_select(".govuk-notification-banner", count: 1) do
            assert_select "*", "Important"
            assert_select "h3", "Question 5 is the start of a route"
            assert_select "p.govuk-body a", "Question 1’s route"
            assert_select "p.govuk-body", /Question 1’s route\s*starts at this question. If you delete this question, the route from it will also be deleted./
          end
        end
      end

      context "when page to delete is at the end of a secondary skip route" do
        let(:pages) do
          [
            build(
              :page,
              :with_selection_settings,
              id: 1,
              form_id: 2,
              position: 1,
              question_text: "What is your favourite colour?",
              selection_options: [{ name: "Red" }, { name: "Green" }, { name: "Blue" }],
              only_one_option: true,
              routing_conditions: [
                build(:condition, routing_page_id: 1, check_page_id: 1, answer_value: "green", goto_page_id: 3),
              ],
            ),
            build(
              :page,
              id: 5,
              form_id: 2,
              position: 5,
              routing_conditions: [
                build(:condition, routing_page_id: 5, check_page_id: 1, answer_value: nil, goto_page_id: 8),
              ],
            ),
            build(
              :page,
              id: 8,
              form_id: 2,
              position: 8,
            ),
          ]
        end

        let(:page) { pages.last }

        it "renders a warning about deleting this page" do
          assert_select(".govuk-notification-banner", count: 1) do
            assert_select "*", "Important"
            assert_select "h3", "Question 8 is at the end of a route"
            assert_select "p.govuk-body a", "Question 1’s route"
            assert_select "p.govuk-body", /Question 1’s route\s*goes to this question. If you delete this question, the route to it will also be deleted./
          end
        end
      end
    end
  end

  describe "#destroy" do
    context "with a valid page" do
      let(:page) do
        build(
          :page,
          id: 1,
          form_id: 2,
          question_text: "What is your work address?",
          hint_text: "This should be the location stated in your contract.",
          answer_type: "address",
        )
      end

      let(:form_pages_response) do
        [page].to_json
      end

      before do
        allow(FormRepository).to receive_messages(find: form_response, pages: form_pages_response)
        allow(PageRepository).to receive_messages(find: page, destroy: true)

        GroupForm.create!(form_id: 2, group_id: group.id)
      end

      context "when the user has confirmed they want to delete the form" do
        before do
          delete destroy_page_path(form_id: 2, page_id: 1, pages_delete_confirmation_input: { confirm: "yes" })
        end

        it "redirects you to the page index screen" do
          expect(response).to redirect_to(form_pages_path)
        end

        it "displays a success flash message" do
          expect(flash[:success]).to eq "Successfully deleted ‘What is your work address?’"
        end

        it "destroys the page through the page repository" do
          expect(PageRepository).to have_received(:destroy)
        end

        include_examples "logging"

        context "when current user is not in group for form" do
          let(:membership) { nil }

          it "returns an error" do
            expect(response).to have_http_status :forbidden
          end

          it "does not call destroy through the page repository" do
            expect(PageRepository).not_to have_received(:destroy)
          end
        end
      end

      context "when user has not confirmed whether they want to delete the question or not" do
        before do
          delete destroy_page_path(form_id: 2, page_id: 1, pages_delete_confirmation_input: { confirm: nil })
        end

        it "re-renders the confirm delete view with an error" do
          expect(response).to render_template(:delete)
          expect(response.body).to include "Select ‘Yes’ to delete the question"
        end

        it "does not call destroy through the page repository" do
          expect(PageRepository).not_to have_received(:destroy)
        end
      end
    end
  end

  describe "#move_page" do
    let(:pages) do
      [build(:page, id: 99),
       build(:page, id: 100),
       build(:page, id: 101)]
    end
    let(:form) do
      build(:form, id: 2, pages:)
    end

    before do
      allow(FormRepository).to receive_messages(find: form, pages: pages)
      allow(PageRepository).to receive_messages(find: pages[1], move_page: true)

      GroupForm.create!(form_id: 2, group_id: group.id)
      post move_page_path({ form_id: 1, move_direction: { up: 100 } })
    end

    it "Reads the form from the API" do
      expect(PageRepository).to have_received(:move_page)
    end
  end
end
