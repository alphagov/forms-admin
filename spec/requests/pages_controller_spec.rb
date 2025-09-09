require "rails_helper"

RSpec.describe PagesController, type: :request do
  let(:form) { create(:form) }

  let(:group) { create(:group, organisation: standard_user.organisation) }
  let(:membership) { create :membership, group:, user: standard_user }

  before do
    membership
    login_as_standard_user
  end

  shared_examples "logging", :capture_logging do
    it "logs the answer type" do
      expect(log_line["answer_type"]).to eq(page.answer_type)
    end
  end

  describe "#index" do
    let(:form) { create(:form, :with_pages) }
    let(:pages) { form.pages }

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
      let(:form) { create(:form) }
      let(:other_group) { create(:group) }

      before do
        other_group.group_forms.create!(form_id: form.id)
        get form_pages_path(form.id)
      end

      it "Renders the forbidden page" do
        expect(response).to render_template("errors/forbidden")
      end

      it "Returns a 403 status" do
        expect(response.status).to eq(403)
      end
    end

    describe "when there are validation errors" do
      let(:form) { create(:form, :ready_for_routing) }

      before do
        create(:condition, routing_page_id: pages.first.id, check_page_id: pages.first.id, answer_value: nil, goto_page_id: pages.last.id)
        pages.first.reload

        allow(standard_user).to receive(:collect_analytics?).and_return(collect_analytics)

        group.group_forms.create!(form_id: form.id)
        get form_pages_path(form.id)
      end

      context "when analytics is enabled" do
        let(:collect_analytics) { true }

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
    let(:original_draft_question) { create :draft_question, form_id: form.id, user: standard_user }

    before do
      allow(FormRepository).to receive(:find).and_return(form)

      GroupForm.create!(form_id: form.id, group_id: group.id)
    end

    it "clears draft questions data for current user and form" do
      original_draft_question # Setup initial draft question which will clear
      expect {
        get start_new_question_path(form_id: form.id)
      }.to change { DraftQuestion.exists?({ form_id: form.id, user: standard_user }) }.from(true).to(false)
    end

    it "does not clear draft questions data for a different form" do
      create :draft_question, form_id: 99, user: standard_user # Setup initial draft question which should not clear
      get start_new_question_path(form_id: form.id)
      expect(DraftQuestion.exists?({ form_id: 99, user: standard_user })).to be true
    end

    it "redirects to type_of_answer_create_path" do
      get start_new_question_path(form_id: form.id)
      expect(response).to redirect_to(type_of_answer_create_path(form_id: form.id))
    end
  end

  describe "#delete" do
    context "with a valid page" do
      let(:page) do
        create(
          :page,
          form_id: form.id,
          question_text: "What is your work address?",
          hint_text: "This should be the location stated in your contract.",
          answer_type: "address",
          is_optional: false,
        )
      end

      let(:pages) { [page] }

      before do
        allow(FormRepository).to receive_messages(find: form, pages: pages)

        pages.each do |page|
          allow(PageRepository).to receive(:find).with(page_id: page.id.to_s, form_id: form.id).and_return(page)
          allow(PageRepository).to receive(:find).with(page_id: page.id, form_id: form.id).and_return(page)
        end

        allow(PageRepository).to receive(:destroy)

        GroupForm.create!(form_id: form.id, group_id: group.id)
      end

      it "renders the delete page template" do
        get delete_page_path(form_id: form.id, page_id: page.id)

        expect(response).to render_template("pages/delete")
      end

      it "reads the form through the page repository" do
        get delete_page_path(form_id: form.id, page_id: page.id)

        expect(PageRepository).to have_received(:find)
      end

      describe "logging" do
        before do
          get delete_page_path(form_id: form.id, page_id: page.id)
        end

        include_examples "logging"
      end

      context "when current user is not in group for form the page is in" do
        let(:membership) { nil }

        it "returns an error" do
          get delete_page_path(form_id: form.id, page_id: page.id)

          expect(response).to have_http_status :forbidden
        end
      end

      context "when page to delete has no routes" do
        it "does not render a warning" do
          get delete_page_path(form_id: form.id, page_id: page.id)

          expect(response.body).not_to include "Important"
        end
      end

      context "when page to delete is start of one or more routes" do
        let(:form) { create(:form, :ready_for_routing) }
        let(:pages) { form.pages }
        let(:page) { pages.first }

        before do
          create(:condition, routing_page_id: page.id, check_page_id: page.id, answer_value: "Red", goto_page_id: pages.last.id)
          page.reload
        end

        it "renders a warning about deleting this page" do
          get delete_page_path(form_id: form.id, page_id: page.id)

          assert_select(".govuk-notification-banner", count: 1) do
            assert_select "*", "Important"
            assert_select "h3", "Question #{page.position} is the start of a route"
            assert_select "p.govuk-body", /If you delete this question, its routes will also be deleted/
            assert_select "p.govuk-body a", "View question #{page.position}’s routes"
          end
        end
      end

      context "when page to delete is at the end of a route" do
        let(:form) { create(:form, :ready_for_routing) }
        let(:pages) { form.pages }
        let(:page) { pages.last }

        before do
          create(:condition, routing_page_id: pages.first.id, check_page_id: pages.first.id, answer_value: "Red", goto_page_id: page.id)
          page.reload
          pages.first.reload
        end

        it "renders a warning about deleting this page" do
          get delete_page_path(form_id: form.id, page_id: page.id)

          assert_select(".govuk-notification-banner", count: 1) do
            assert_select "*", "Important"
            assert_select "h3", "Question 5 is at the end of a route"
            assert_select "p.govuk-body a", "Question 1’s route"
            assert_select "p.govuk-body", /Question 1’s route\s*goes to this question. If you delete this question, question 1’s routes will also be deleted./
          end
        end
      end

      context "when page to delete is start of a secondary skip route" do
        let(:form) { create(:form, :ready_for_routing) }
        let(:pages) { form.pages }
        let(:page) { pages.second }

        before do
          create(:condition, routing_page_id: pages.first.id, check_page_id: pages.first.id, answer_value: "Red", goto_page_id: pages.third.id)
          create(:condition, routing_page_id: page.id, check_page_id: pages.first.id, answer_value: nil, goto_page_id: pages.last.id)
          page.reload
        end

        it "renders a warning about deleting this page" do
          get delete_page_path(form_id: form.id, page_id: page.id)

          assert_select(".govuk-notification-banner", count: 1) do
            assert_select "*", "Important"
            assert_select "h3", "Question 2 is the start of a route"
            assert_select "p.govuk-body a", "Question 1’s route"
            assert_select "p.govuk-body", /Question 1’s route\s*starts at this question. If you delete this question, the route from it will also be deleted./
          end
        end
      end

      context "when page to delete is at the end of a secondary skip route" do
        let(:form) { create(:form, :ready_for_routing) }
        let(:pages) { form.pages }
        let(:page) { pages.last }

        before do
          create(:condition, routing_page_id: pages.first.id, check_page_id: pages.first.id, answer_value: "Red", goto_page_id: pages.third.id)
          create(:condition, routing_page_id: pages.second.id, check_page_id: pages.first.id, answer_value: nil, goto_page_id: pages.last.id)
          pages.second.reload
        end

        it "renders a warning about deleting this page" do
          get delete_page_path(form_id: form.id, page_id: page.id)

          assert_select(".govuk-notification-banner", count: 1) do
            assert_select "*", "Important"
            assert_select "h3", "Question 5 is at the end of a route"
            assert_select "p.govuk-body a", "Question 1’s route"
            assert_select "p.govuk-body", /Question 1’s route\s*goes to this question. If you delete this question, the route to it will also be deleted./
          end
        end
      end
    end
  end

  describe "#destroy" do
    let(:form) { create(:form, :with_pages) }
    let(:pages) { form.pages }
    let(:page) { pages.first }

    context "with a valid page" do
      before do
        allow(FormRepository).to receive_messages(find: form, pages: pages)
        allow(PageRepository).to receive_messages(find: page, destroy: true)

        GroupForm.create!(form_id: form.id, group_id: group.id)
      end

      context "when the user has confirmed they want to delete the form" do
        before do
          delete destroy_page_path(form_id: form.id, page_id: page.id, pages_delete_confirmation_input: { confirm: "yes" })
        end

        it "redirects you to the page index screen" do
          expect(response).to redirect_to(form_pages_path)
        end

        it "displays a success flash message" do
          expect(flash[:success]).to eq "Successfully deleted ‘#{page.question_text}’"
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
          delete destroy_page_path(form_id: form.id, page_id: page.id, pages_delete_confirmation_input: { confirm: nil })
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
    let(:form) { create(:form, :with_pages) }
    let(:pages) { form.pages }

    before do
      allow(FormRepository).to receive_messages(find: form, pages: pages)
      allow(PageRepository).to receive_messages(find: pages[1])

      GroupForm.create!(form_id: form.id, group_id: group.id)
    end

    context "when moving the page up" do
      before do
        allow(PageRepository).to receive(:move_page) do |page, _direction|
          page.move_higher
          page
        end

        post move_page_path({ form_id: form.id, move_direction: { up: pages[1].id } })
      end

      it "calls the page repository to move the page up" do
        expect(PageRepository).to have_received(:move_page).with(pages[1], :up)
      end

      it "renders a success banner with the page's new position" do
        expect(flash[:success]).to eq("‘#{pages[1].question_text}’ has moved up to number 1")
      end
    end

    context "when moving the page down" do
      before do
        allow(PageRepository).to receive(:move_page) do |page, _direction|
          page.move_lower
          page
        end

        post move_page_path({ form_id: form.id, move_direction: { down: pages[1].id } })
      end

      it "calls the page repository to move the page down" do
        expect(PageRepository).to have_received(:move_page).with(pages[1], :down)
      end

      it "renders a success banner with the page's new position" do
        expect(flash[:success]).to eq("‘#{pages[1].question_text}’ has moved down to number 3")
      end
    end
  end
end
