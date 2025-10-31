require "rails_helper"

RSpec.describe Pages::ChangeOrderController, type: :request do
  let(:form) { create :form, :with_pages, pages_count: 3 }
  let(:group) { create(:group, organisation: standard_user.organisation) }

  before do
    Membership.create!(group_id: group.id, user: standard_user, added_by: standard_user)
    GroupForm.create!(form_id: form.id, group_id: group.id)
    login_as_standard_user
  end

  describe "#new" do
    before do
      get change_order_new_path(form_id: form.id)
    end

    it "renders the template" do
      expect(response).to have_rendered("pages/change_order")
    end
  end

  describe "#create" do
    before do
      post(change_order_new_path(form_id: form.id), params:)
    end

    context "when updating the preview" do
      let(:params) do
        {
          pages_change_order_input:,
          preview: "true",
        }
      end

      context "when the input is valid" do
        let(:pages_change_order_input) do
          {
            "position_for_page_#{form.pages[0].id}" => "2",
            "position_for_page_#{form.pages[1].id}" => "",
            "position_for_page_#{form.pages[2].id}" => "",
          }
        end

        it "renders the template" do
          expect(response).to have_rendered("pages/change_order")
        end

        it "shows a banner" do
          expect(response.body).to include("You need to save this question order if you want to keep these changes")
        end

        it "updates the page positions" do
          node = Capybara.string(response.body)
          expect(node).to have_xpath("//dl/div[1]/dd/h3", text: form.pages[1].question_text)
        end
      end

      context "when the input is invalid" do
        let(:pages_change_order_input) do
          {
            "position_for_page_#{form.pages[0].id}" => "0",
            "position_for_page_#{form.pages[1].id}" => "",
            "position_for_page_#{form.pages[2].id}" => "",
          }
        end

        it "renders an error summary" do
          expect(response.body).to include("There is a problem")
        end

        it "does not update the question positions" do
          node = Capybara.string(response.body)
          expect(node).to have_xpath("//dl/div[1]/dd/h3", text: form.pages[0].question_text)
        end
      end
    end

    context "when submitting" do
      let(:params) do
        {
          pages_change_order_input: {
            "position_for_page_#{form.pages[0].id}" => "2",
            "position_for_page_#{form.pages[1].id}" => "",
            "position_for_page_#{form.pages[2].id}" => "",
            confirm:,
          },
        }
      end

      context "when the input is valid" do
        context "when 'yes' was selected" do
          let(:confirm) { "yes" }

          it "redirects to the form_pages_path" do
            expect(response).to redirect_to(form_pages_path)
          end

          it "shows a success message" do
            expect(flash[:success]).to eq("Your new question order has been saved")
          end

          context "when a page has been added to the form during changing the page order" do
            let(:params) do
              {
                pages_change_order_input: {
                  "position_for_page_#{form.pages[0].id}" => "2",
                  "position_for_page_#{form.pages[1].id}" => "",
                  confirm:,
                },
              }
            end

            it "renders an error template" do
              expect(response).to have_rendered("errors/change_order_pages_added")
            end
          end
        end

        context "when 'no' was selected" do
          let(:confirm) { "no" }

          it "redirects to the form_pages_path" do
            expect(response).to redirect_to(form_pages_path)
          end
        end
      end

      context "when the input is invalid" do
        let(:confirm) { nil }

        it "renders the change_order template" do
          expect(response).to have_rendered("pages/change_order")
        end

        it "renders an error summary" do
          expect(response.body).to include("There is a problem")
        end

        it "does not update the question positions" do
          node = Capybara.string(response.body)
          expect(node).to have_xpath("//dl/div[1]/dd/h3", text: form.pages[0].question_text)
        end
      end
    end
  end
end
