require "rails_helper"

RSpec.describe Pages::SecondarySkipController, type: :request do
  let(:form) { create :form, :with_pages }
  let(:pages) { form.pages }
  let(:page) do
    pages.first.tap do |first_page|
      first_page.is_optional = false
      first_page.answer_type = "selection"
      first_page.answer_settings = DataStruct.new(
        only_one_option: true,
        selection_options: [OpenStruct.new(attributes: { name: "Option 1" }),
                            OpenStruct.new(attributes: { name: "Option 2" })],
      )
    end
  end

  let(:group) { create(:group, organisation: standard_user.organisation) }

  RSpec.shared_examples "requires condition" do |action|
    it "redirects to the page list" do
      send(action)
      expect(response).to redirect_to(form_pages_path(form.id))
    end
  end

  before do
    Membership.create!(group_id: group.id, user: standard_user, added_by: standard_user)
    GroupForm.create!(form_id: form.id, group_id: group.id)
    login_as_standard_user

    allow(ConditionRepository).to receive_messages(find: {}, save!: {}, destroy: {})
  end

  describe "#new" do
    subject(:get_new) { get new_secondary_skip_path(form_id: form.id, page_id: page.id) }

    context "when no condition exists on the page" do
      it_behaves_like "requires condition", :subject
    end

    context "when a condition exists on the page" do
      before do
        create(:condition, routing_page_id: page.id, check_page_id: page.id, answer_value: "Option 1", goto_page_id: pages[2].id, skip_to_end: false)
        page.reload
      end

      it "returns 200" do
        get_new
        expect(response).to have_http_status(:success)
      end

      context "when a secondary skip condition already exists on the page" do
        before do
          create(:condition, routing_page_id: pages[1].id, check_page_id: page.id, goto_page_id: pages[4].id)
          page.reload
          pages[1].reload
        end

        it "redirects to the show routes page" do
          get_new
          expect(response).to redirect_to(show_routes_path(form_id: form.id, page_id: page.id))
        end
      end
    end
  end

  describe "#create" do
    subject(:post_create) { post create_secondary_skip_path(form_id: form.id, page_id: page.id), params: valid_params }

    let(:valid_params) do
      {
        form_id: form.id.to_s,
        page_id: page.id.to_s,
        pages_secondary_skip_input: {
          routing_page_id: pages[1].id.to_s,
          goto_page_id: pages[4].id.to_s,
        },
      }
    end

    context "when no condition exists on the page" do
      it_behaves_like "requires condition", :subject
    end

    context "when a condition exists on the page" do
      before do
        create(:condition, routing_page_id: page.id, check_page_id: page.id, answer_value: "Option 1", goto_page_id: pages[2].id, skip_to_end: false)
        page.reload
      end

      context "when the submission is successful" do
        it "redirects to the show routes page" do
          post_create
          expect(response).to redirect_to(show_routes_path(form_id: form.id, page_id: page.id))
        end
      end

      context "when a secondary skip condition already exists on the page" do
        before do
          create(:condition, routing_page_id: pages[1].id, check_page_id: page.id, goto_page_id: pages[4].id)
          page.reload
          pages[1].reload
        end

        it "redirects to the show routes page" do
          post_create
          expect(response).to redirect_to(show_routes_path(form_id: form.id, page_id: page.id))
        end
      end

      context "when the submission fails" do
        subject(:post_create) { post create_secondary_skip_path(form_id: form.id, page_id: page.id), params: invalid_params }

        let(:invalid_params) do
          {
            form_id: form.id.to_s,
            page_id: page.id.to_s,
            pages_secondary_skip_input: {
              routing_page_id: page.id.to_s,
              goto_page_id: page.id.to_s,
            },
          }
        end

        it "renders the new template" do
          post_create
          expect(response).to have_http_status(:unprocessable_content)
          expect(response).to render_template("pages/secondary_skip/new")
        end
      end
    end
  end

  describe "#edit" do
    subject(:get_edit) { get edit_secondary_skip_path(form_id: form.id, page_id: page.id) }

    context "when no condition exists on the page" do
      it_behaves_like "requires condition", :subject
    end

    context "when a condition exists on the page" do
      before do
        create(:condition, routing_page_id: page.id, check_page_id: page.id, answer_value: "Option 1", goto_page_id: pages[2].id, skip_to_end: false)
        page.reload
      end

      context "when no secondary_skip exists on the page" do
        it "redirects to the show routes page" do
          get_edit
          expect(response).to redirect_to(show_routes_path(form_id: form.id, page_id: page.id))
        end
      end

      context "when a secondary_skip exists on the page" do
        before do
          create(:condition, routing_page_id: pages[1].id, check_page_id: page.id, goto_page_id: pages[4].id)
          page.reload
          pages[1].reload
        end

        it "renders the edit template" do
          get_edit
          expect(response).to have_http_status(:success)
          expect(response).to render_template("pages/secondary_skip/edit")
        end
      end
    end
  end

  describe "#update" do
    subject(:post_update) { post update_secondary_skip_path(form_id: form.id, page_id: page.id), params: valid_params }

    let(:valid_params) do
      {
        form_id: form.id.to_s,
        page_id: page.id.to_s,
        pages_secondary_skip_input: {
          routing_page_id: pages[1].id.to_s,
          goto_page_id: pages[4].id.to_s,
        },
      }
    end

    context "when no condition exists on the page" do
      it_behaves_like "requires condition", :subject
    end

    context "when a condition exists on the page" do
      before do
        create(:condition, routing_page_id: page.id, check_page_id: page.id, answer_value: "Option 1", goto_page_id: pages[2].id, skip_to_end: false)
        page.reload
      end

      context "when no secondary_skip exists on the page" do
        it "redirects to the show routes page" do
          post_update
          expect(response).to redirect_to(show_routes_path(form_id: form.id, page_id: page.id))
        end
      end

      context "when a secondary_skip exists on the page" do
        before do
          create(:condition, routing_page_id: pages[1].id, check_page_id: page.id, goto_page_id: pages[4].id)
          page.reload
          pages[1].reload
        end

        context "when the submission is successful without changing the routing_page_id" do
          it "redirects to the show routes page" do
            post_update
            expect(response).to redirect_to(show_routes_path(form_id: form.id, page_id: page.id))
          end
        end

        context "when the submission is successful and changes the routing_page_id" do
          let(:valid_params) do
            {
              form_id: form.id.to_s,
              page_id: page.id.to_s,
              pages_secondary_skip_input: {
                routing_page_id: pages[2].id.to_s,
                goto_page_id: pages[4].id.to_s,
              },
            }
          end

          it "redirects to the show routes page" do
            post_update
            expect(response).to redirect_to(show_routes_path(form_id: form.id, page_id: page.id))
          end
        end

        context "when the submission fails" do
          subject(:post_update) { post update_secondary_skip_path(form_id: form.id, page_id: page.id), params: invalid_params }

          let(:invalid_params) do
            {
              form_id: form.id.to_s,
              page_id: page.id.to_s,
              pages_secondary_skip_input: {
                routing_page_id: pages[2].id.to_s,
                goto_page_id: pages[2].id.to_s,
              },
            }
          end

          it "renders the edit template" do
            post_update
            expect(response).to have_http_status(:unprocessable_content)
            expect(response).to render_template("pages/secondary_skip/edit")
          end
        end
      end
    end
  end

  describe "#delete" do
    context "when no condition exists on the page" do
      it "redirects to the page list" do
        get delete_secondary_skip_path(form_id: form.id, page_id: page.id)
        expect(response).to redirect_to(form_pages_path(form.id))
      end
    end

    context "when a condition exists on the page" do
      before do
        create(:condition, routing_page_id: page.id, check_page_id: page.id, answer_value: "Option 1", goto_page_id: pages[2].id, skip_to_end: false)
        page.reload
      end

      context "when no secondary_skip exists on the page" do
        it "redirects to the show routes page" do
          get delete_secondary_skip_path(form_id: form.id, page_id: page.id)
          expect(response).to redirect_to(show_routes_path(form_id: form.id, page_id: page.id))
        end
      end

      context "when a secondary_skip exists on the page" do
        before do
          create(:condition, routing_page_id: pages[1].id, check_page_id: page.id, goto_page_id: pages[4].id)
          page.reload
          pages[1].reload
        end

        it "returns 200" do
          get delete_secondary_skip_path(form_id: form.id, page_id: page.id)
          expect(response).to have_http_status(:success)
        end

        it "renders the delete template" do
          get delete_secondary_skip_path(form_id: form.id, page_id: page.id)
          expect(response).to render_template("pages/secondary_skip/delete")
        end
      end
    end
  end

  describe "#destroy" do
    context "when no condition exists on the page" do
      it "redirects to the page list" do
        delete destroy_secondary_skip_path(form_id: form.id, page_id: page.id)
        expect(response).to redirect_to(form_pages_path(form.id))
      end
    end

    context "when a condition exists on the page" do
      before do
        create(:condition, routing_page_id: page.id, check_page_id: page.id, answer_value: "Option 1", goto_page_id: pages[2].id, skip_to_end: false)
        page.reload
      end

      context "when no secondary_skip exists on the page" do
        it "redirects to the show routes page" do
          delete destroy_secondary_skip_path(form_id: form.id, page_id: page.id)
          expect(response).to redirect_to(show_routes_path(form_id: form.id, page_id: page.id))
        end
      end

      context "when a secondary_skip exists on the page" do
        before do
          create(:condition, routing_page_id: pages[1].id, check_page_id: page.id, goto_page_id: pages[4].id)
          page.reload
          pages[1].reload
        end

        context "when the submission is successful and deletes the secondary skip condition" do
          let(:valid_params) do
            {
              form_id: form.id.to_s,
              page_id: page.id.to_s,
              pages_delete_secondary_skip_input: {
                confirm: "yes",
              },
            }
          end

          it "redirects to the show routes page" do
            delete destroy_secondary_skip_path(form_id: form.id, page_id: page.id), params: valid_params
            expect(response).to redirect_to(show_routes_path(form_id: form.id, page_id: page.id))
          end
        end

        context "when the submission fails" do
          let(:invalid_params) do
            {
              form_id: form.id.to_s,
              page_id: page.id.to_s,
              pages_delete_secondary_skip_input: {
                confirm: "maybe",
              },
            }
          end

          it "renders the delete template" do
            delete destroy_secondary_skip_path(form_id: form.id, page_id: page.id), params: invalid_params
            expect(response).to have_http_status(:unprocessable_content)
            expect(response).to render_template("pages/secondary_skip/delete")
          end
        end
      end
    end
  end
end
