require "rails_helper"

describe "forms/welsh_translation/new.html.erb" do
  let(:form) { build_form }
  let(:page) { create :page, position: 1 }
  let(:another_page) { create :page, position: 2 }
  let(:welsh_page_translation_input) { Forms::WelshPageTranslationInput.new(id: page.id).assign_page_values }
  let(:another_welsh_page_translation_input) { Forms::WelshPageTranslationInput.new(id: another_page.id).assign_page_values }
  let(:welsh_translation_input) { Forms::WelshTranslationInput.new(form:, page_translations: [welsh_page_translation_input, another_welsh_page_translation_input]).assign_form_values }

  def build_form(attributes = {})
    default_attributes = {
      id: 1,
      name: "My form",
      name_cy: "My Welsh form",
      what_happens_next_markdown: "English what happens next",
      what_happens_next_markdown_cy: "Welsh what happens next",
      privacy_policy_url: "https://www.gov.uk/privacy",
      privacy_policy_url_cy: "https://www.gov.uk/privacy_cy",
      payment_url: "https://www.gov.uk/payment",
      payment_url_cy: "https://www.gov.uk/payment_cy",
      support_email: "support@example.gov.uk",
      support_phone: "English support phone",
      support_url: "https://www.gov.uk/support",
      support_url_text: "Support URL text",
      declaration_text: "Declaration text", # no welsh version to test nil
      pages: [page, another_page],
    }
    build(:form, default_attributes.merge(attributes))
  end

  context "when the form has no errors" do
    before do
      assign(:welsh_translation_input, welsh_translation_input)
      render
    end

    it "contains page heading and sub-heading" do
      expect(rendered).to have_css("h1 .govuk-caption-l", text: form.name)
      expect(rendered).to have_css("h1.govuk-heading-l", text: "Add a Welsh version of your form")
    end

    it "renders a text input for 'Form name'" do
      expect(rendered).to have_field("Form name", type: "text", with: "My Welsh form")
    end

    it "renders english text for 'Form name'" do
      expect(rendered).to have_text("My form")
    end

    it "renders a text area for 'Declaration'" do
      expect(rendered).to have_field("Declaration", type: "textarea", with: nil)
    end

    it "renders english text for 'Declaration'" do
      expect(rendered).to have_text("Declaration text")
    end

    it "renders a text area for 'What happens next'" do
      expect(rendered).to have_field("What happens next", type: "textarea", with: "Welsh what happens next")
    end

    it "renders english text for 'What happens next'" do
      expect(rendered).to have_text("English what happens next")
    end

    it "renders a text input for 'Privacy policy URL'" do
      expect(rendered).to have_field("Privacy policy URL", type: "text", with: "https://www.gov.uk/privacy_cy")
    end

    it "renders english text for 'Privacy policy URL'" do
      expect(rendered).to have_text("https://www.gov.uk/privacy")
    end

    it "renders a text input for 'Link to a payment page'" do
      expect(rendered).to have_field("Payment URL", type: "text", with: "https://www.gov.uk/payment_cy")
    end

    it "renders english text for 'Link to a payment page'" do
      expect(rendered).to have_text("https://www.gov.uk/payment")
    end

    it "renders text inputs for all the support contact fields" do
      expect(rendered).to have_field("Support email", type: "text")
      expect(rendered).to have_field("Support phone", type: "textarea")
      expect(rendered).to have_field("Support URL", type: "text")
      expect(rendered).to have_field("Support URL text", type: "text")
    end

    it "renders english text for support contact fields" do
      expect(rendered).to have_text("Support email")
      expect(rendered).to have_text("English support phone")
      expect(rendered).to have_text("https://www.gov.uk/support")
      expect(rendered).to have_text("Support URL text")
    end

    it "renders radio buttons for 'finsihed adding your Welsh version?'" do
      expect(rendered).to have_css("legend", text: "Have you finished adding your Welsh version?")
      expect(rendered).to have_field("Yes", type: "radio")
      expect(rendered).to have_field("No", type: "radio")
    end

    it "renders a 'Save and continue' button" do
      expect(rendered).to have_button("Save and continue")
    end

    context "when the form does not have a declaration text" do
      let(:form) { build_form(declaration_text: nil) }

      it "does not render a declaration text area" do
        expect(rendered).not_to have_field("Declaration", type: "textarea")
      end

      it "renders message for no declaration text" do
        expect(rendered).to have_text("No declaration was added to this form.")
      end
    end

    context "when the form has no payment URL" do
      let(:form) { build_form(payment_url: nil) }

      it "does not render a payment URL text input" do
        expect(rendered).not_to have_field("Payment URL", type: "text")
      end
    end

    context "when the form has no support URL" do
      let(:form) { build_form(support_url: nil) }

      it "does not render a support URL text input" do
        expect(rendered).not_to have_field("Support URL", type: "text")
        expect(rendered).not_to have_field("Support URL text", type: "text")
      end
    end

    context "when the form has no support phone" do
      let(:form) { build_form(support_phone: nil) }

      it "does not render a support phone text area" do
        expect(rendered).not_to have_field("Support phone", type: "textarea")
      end
    end

    context "when the form has no support email" do
      let(:form) { build_form(support_email: nil) }

      it "does not render a support email text input" do
        expect(rendered).not_to have_field("Support email", type: "text")
      end
    end

    context "when the form has no support information" do
      let(:form) { build_form(support_email: nil, support_phone: nil, support_url: nil, support_url_text: nil) }

      it "does not render support information" do
        expect(rendered).not_to have_text("Contact details for support", exact: true)
      end

      it "renders message for no support information" do
        expect(rendered).to have_text("No contact details for support were added to this form.")
      end
    end

    context "when the form has no what happens next information" do
      let(:form) { build_form(what_happens_next_markdown: nil) }

      it "does not render what happens next information" do
        expect(rendered).not_to have_field("What happens next", type: "textarea")
      end

      it "renders message for no what happens next information" do
        expect(rendered).to have_text("No information about what happens next was added to this form.")
      end
    end

    context "when the form has no privacy information" do
      let(:form) { build_form(privacy_policy_url: nil) }

      it "does not render privacy information field" do
        expect(rendered).not_to have_field("Privacy policy URL", type: "text")
      end

      it "renders message for no privacy information" do
        expect(rendered).to have_text("No link to privacy information was added to this form.")
      end
    end

    context "when the form has pages" do
      it "has a field for each page's Welsh question text" do
        expect(rendered).to have_field("Question #{page.position} Welsh question text", type: "text")
        expect(rendered).to have_field("Question #{another_page.position} Welsh question text", type: "text")
      end

      context "when a page has hint text" do
        let(:page) { create :page, hint_text: "Choose 'Yes' if you already have a valid licence." }
        let(:another_page) { create :page, hint_text: nil }

        it "shows the English text and Welsh field for pages with English hint text" do
          expect(rendered).to have_css("td", text: page.hint_text)
          expect(rendered).to have_field("Question #{page.position} Welsh hint text", type: "textarea")
        end

        it "does not show the Welsh field for pages without English hint text" do
          expect(rendered).not_to have_field("Question #{another_page.position} Welsh hint text")
        end
      end

      context "when a page has a page heading and guidance markdown" do
        let(:page) { create :page, guidance_markdown: nil, page_heading: nil }
        let(:another_page) { create :page, guidance_markdown: "This part of the form concerns licencing.", page_heading: "Licencing" }

        it "shows the English text and Welsh fields for pages with English page heading and guidance markdown" do
          expect(rendered).to have_css("td", text: page.page_heading)
          expect(rendered).to have_field("Question #{another_page.position} Welsh page heading")
          expect(rendered).to have_css("td", text: page.guidance_markdown)
          expect(rendered).to have_field("Question #{another_page.position} Welsh guidance markdown")
        end

        it "does not show the Welsh field for pages without English page heading and guidance markdown" do
          expect(rendered).not_to have_field("Question #{page.position} Welsh page heading", type: "text")
          expect(rendered).not_to have_field("Question #{page.position} Welsh guidance markdown", type: "textarea")
        end

        it "shows a field for Welsh page heading and guidance markdown on pages with English page heading and guidance markdown" do
          expect(rendered).to have_field("Question #{another_page.position} Welsh page heading")
          expect(rendered).to have_field("Question #{another_page.position} Welsh guidance markdown")
        end
      end
    end
  end

  context "when the form has validation errors" do
    before do
      welsh_translation_input.mark_complete = nil
      welsh_translation_input.validate

      assign(:welsh_translation_input, welsh_translation_input)
      render
    end

    it "displays an error summary box" do
      expect(rendered).to have_css(".govuk-error-summary")
      expect(rendered).to have_css("h2.govuk-error-summary__title", text: "There is a problem")
    end

    it "links the error summary to the invalid field" do
      error_message = I18n.t("activemodel.errors.models.forms/welsh_translation_input.attributes.mark_complete.blank")
      expect(rendered).to have_link(error_message, href: "#forms-welsh-translation-input-mark-complete-field-error")
    end

    it "adds an inline error message to the invalid field" do
      error_message = "Error: #{I18n.t('activemodel.errors.models.forms/welsh_translation_input.attributes.mark_complete.blank')}"
      expect(rendered).to have_css(".govuk-error-message", text: error_message)
    end
  end
end
