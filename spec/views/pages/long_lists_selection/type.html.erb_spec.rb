require "rails_helper"

describe "pages/long_lists_selection/type.html.erb", type: :view do
  let(:form) { build :form, id: 1 }
  let(:page) { build :page, routing_conditions: }
  let(:page_number) { 1 }
  let(:back_link_url) { "/a-back-link-url" }
  let(:selection_type_path) { "/a-path" }
  let(:only_one_option) { "true" }
  let(:draft_question) { build :draft_question, answer_type: "selection" }
  let(:routing_conditions) { [] }
  let(:selection_type_input) { Pages::Selection::TypeInput.new(only_one_option:, draft_question:) }

  before do
    # # mock the form.page_number method
    allow(form).to receive(:page_number).and_return(page_number)

    # # mock the path helper
    without_partial_double_verification do
      allow(view).to receive_messages(form_pages_path: "/pages", current_form: form)
    end

    # # setup instance variables
    assign(:page, page)
    assign(:selection_type_path, selection_type_path)
    assign(:back_link_url, back_link_url)
    assign(:selection_type_input, selection_type_input)
  end

  describe "only one option radios" do
    before do
      render(template: "pages/long_lists_selection/type")
    end

    context "when input object has value of true" do
      let(:only_one_option) { "true" }

      it "has 'Yes' radio selected" do
        expect(rendered).to have_checked_field("pages_selection_type_input[only_one_option]", with: "true")
        expect(rendered).to have_unchecked_field("pages_selection_type_input[only_one_option]", with: "false")
      end
    end

    context "when input object has value of false" do
      let(:only_one_option) { "false" }

      it "has 'No' radio selected" do
        expect(rendered).to have_checked_field("pages_selection_type_input[only_one_option]", with: "false")
        expect(rendered).to have_unchecked_field("pages_selection_type_input[only_one_option]", with: "true")
      end
    end

    context "when input object has no value set" do
      let(:only_one_option) { nil }

      it "does not have a radio option selected" do
        expect(rendered).to have_unchecked_field("pages_selection_type_input[only_one_option]", with: "true")
        expect(rendered).to have_unchecked_field("pages_selection_type_input[only_one_option]", with: "false")
      end
    end
  end

  describe "warnings" do
    describe "routing warning" do
      context "when creating a new question" do
        it "does not display a warning about routes being deleted if only one option changes" do
          render(template: "pages/long_lists_selection/type")
          expect(rendered).not_to have_selector(".govuk-notification-banner")
        end
      end

      context "when editing an existing question" do
        let(:form) { build :form, id: 1, pages: [page] }

        context "when no routing conditions set" do
          it "does not display a warning about routes being deleted" do
            render(template: "pages/long_lists_selection/type")
            expect(rendered).not_to have_selector(".govuk-notification-banner__content")
          end
        end

        context "when a routing condition is set" do
          let(:routing_conditions) { [(build :condition)] }

          context "when the options will not need to be reduced" do
            before do
              allow(selection_type_input).to receive(:need_to_reduce_options?).and_return false
              render(template: "pages/long_lists_selection/type")
            end

            it "displays a warning about routes being deleted" do
              expect(rendered).to have_selector(".govuk-notification-banner__content", text: I18n.t("selection_type.routing_warning"))
            end
          end

          context "when a routing condition is set and the options will need to be reduced" do
            before do
              allow(selection_type_input).to receive(:need_to_reduce_options?).and_return true
              render(template: "pages/long_lists_selection/type")
            end

            it "displays a combined warning about routes being deleted and needing to reduce the options" do
              expect(rendered).to have_selector(".govuk-notification-banner__content", text: I18n.t("selection_type.routing_and_reduce_your_options_combined_warning.heading"))
            end
          end
        end
      end
    end

    describe "reduce your options warning" do
      context "when the options will not need to be reduced" do
        before do
          allow(selection_type_input).to receive(:need_to_reduce_options?).and_return false
          render(template: "pages/long_lists_selection/type")
        end

        it "does not display a warning about reducing the number of options" do
          expect(rendered).not_to have_selector(".govuk-notification-banner")
        end
      end

      context "when the options will need to be reduced" do
        before do
          allow(selection_type_input).to receive(:need_to_reduce_options?).and_return true
          render(template: "pages/long_lists_selection/type")
        end

        it "does not display a warning about reducing the number of options" do
          expect(rendered).to have_selector(".govuk-notification-banner__content", text: I18n.t("selection_type.reduce_your_options_warning.heading"))
        end
      end
    end
  end
end
