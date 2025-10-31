require "rails_helper"

RSpec.describe Forms::WelshTranslationInput, type: :model do
  subject(:welsh_translation_input) { described_class.new(new_input_data) }

  let(:form) { build_form }
  let(:page) { create :page }
  let(:another_page) { create :page }

  let(:new_input_data) do
    {
      form:,
      mark_complete: "true",
      what_happens_next_markdown_cy: "New Welsh what happens next",
      declaration_text_cy: "New Welsh declaration",
      support_email_cy: "new-welsh-support@example.gov.uk",
      support_phone_cy: "0800 123 4567",
      support_url_cy: "https://www.gov.uk/new-welsh-support",
      support_url_text_cy: "New Welsh Support",
      privacy_policy_url_cy: "https://www.gov.uk/new-welsh-privacy",
      payment_url_cy: "https://www.gov.uk/new-welsh-payment",
    }
  end

  def build_form(attributes = {})
    default_attributes = {
      id: 1,
      name: "Apply for a juggling licence",
      what_happens_next_markdown: "English what happens next",
      welsh_completed: false,
      what_happens_next_markdown_cy: "Welsh what happens next",
      declaration_text: "English declaration",
      declaration_text_cy: "Welsh declaration",
      support_email: "english-support@example.gov.uk",
      support_email_cy: "welsh-support@example.gov.uk",
      support_phone: "01234 987654",
      support_phone_cy: "01234 567891",
      support_url_cy: "https://www.gov.uk/welsh-support",
      support_url: "https://www.gov.uk/english-support",
      support_url_text_cy: "Welsh Support",
      support_url_text: "English Support",
      privacy_policy_url_cy: "https://www.gov.uk/welsh-privacy",
      payment_url: "https://www.gov.uk/english-payment",
      payment_url_cy: "https://www.gov.uk/welsh-payment",
    }
    build(:form, default_attributes.merge(attributes))
  end

  describe "validations" do
    it "is not valid if mark complete is blank" do
      form = OpenStruct.new(welsh_completed: false, name: "Apply for a juggling licence")
      welsh_translation_input = described_class.new(mark_complete: nil, form:)

      expect(welsh_translation_input).not_to be_valid
      expect(welsh_translation_input.errors.full_messages_for(:mark_complete)).to include "Mark complete #{I18n.t('activemodel.errors.models.forms/welsh_translation_input.attributes.mark_complete.blank')}"
    end
  end

  describe "#submit" do
    context "when the data is invalid" do
      let(:new_input_data) { super().merge(mark_complete: nil) }

      it "returns false" do
        expect(welsh_translation_input.submit).to be false
      end

      it "does not update the form's attributes" do
        original_attributes = form.attributes.clone
        welsh_translation_input.submit
        expect(form.attributes).to eq(original_attributes)
      end
    end

    context "when the data is valid" do
      it "returns true" do
        expect(welsh_translation_input.submit).to be true
      end

      it "updates the form's welsh attributes with the new values" do
        welsh_translation_input.submit

        expect(form.welsh_completed).to be true
        expect(form.what_happens_next_markdown_cy).to eq(new_input_data[:what_happens_next_markdown_cy])
        expect(form.declaration_text_cy).to eq(new_input_data[:declaration_text_cy])
        expect(form.support_email_cy).to eq(new_input_data[:support_email_cy])
        expect(form.support_phone_cy).to eq(new_input_data[:support_phone_cy])
        expect(form.support_url_cy).to eq(new_input_data[:support_url_cy])
        expect(form.support_url_text_cy).to eq(new_input_data[:support_url_text_cy])
        expect(form.privacy_policy_url_cy).to eq(new_input_data[:privacy_policy_url_cy])
        expect(form.payment_url_cy).to eq(new_input_data[:payment_url_cy])
      end

      it "does not update any non-welsh attributes" do
        english_value_before = form.what_happens_next_markdown
        welsh_translation_input.submit
        expect(form.what_happens_next_markdown).to eq(english_value_before)
      end

      context "when the form has no declaration text" do
        let(:form) { build_form(declaration_text: nil) }

        it "clears the Welsh declaration text" do
          welsh_translation_input.submit
          expect(form.declaration_text_cy).to be_nil
        end
      end

      context "when the form has no payment URL" do
        let(:form) { build_form(payment_url: nil) }

        it "clears the Welsh payment URL" do
          welsh_translation_input.submit
          expect(form.payment_url_cy).to be_nil
        end
      end

      context "when the form has no support URL" do
        let(:form) { build_form(support_url: nil) }

        it "clears the Welsh support URL" do
          welsh_translation_input.submit
          expect(form.support_url_cy).to be_nil
        end

        it "clears the Welsh support URL text" do
          welsh_translation_input.submit
          expect(form.support_url_text_cy).to be_nil
        end
      end

      context "when the form has no support phone" do
        let(:form) { build_form(support_phone: nil) }

        it "clears the Welsh support phone" do
          welsh_translation_input.submit
          expect(form.support_phone_cy).to be_nil
        end
      end

      context "when the form has no support email" do
        let(:form) { build_form(support_email: nil) }

        it "clears the Welsh support email" do
          welsh_translation_input.submit
          expect(form.support_email_cy).to be_nil
        end
      end

      context "when the form includes page translation objects" do
        let(:page_translation) { Forms::WelshPageTranslationInput.new(id: page.id, question_text_cy: "Ydych chi'n adnewyddu trwydded?", hint_text_cy: "Dewiswch 'Ydw' os oes gennych drwydded ddilys eisoes.") }
        let(:another_page_translation) { Forms::WelshPageTranslationInput.new(id: another_page.id, question_text_cy: "Ydych chi'n adnewyddu trwydded?") }

        let(:new_input_data) { super().merge(page_translations: [page_translation, another_page_translation]) }

        it "submits the data on the page translation objects" do
          welsh_translation_input.submit

          expect(page.reload.question_text_cy).to eq("Ydych chi'n adnewyddu trwydded?")
          expect(page.reload.hint_text_cy).to eq("Dewiswch 'Ydw' os oes gennych drwydded ddilys eisoes.")
          expect(another_page.reload.question_text_cy).to eq("Ydych chi'n adnewyddu trwydded?")
        end
      end
    end
  end

  describe "#assign_form_values" do
    it "loads the existing welsh attributes from the form" do
      welsh_translation_input = described_class.new(form:)
      welsh_translation_input.assign_form_values

      expect(welsh_translation_input.what_happens_next_markdown_cy).to eq(form.what_happens_next_markdown_cy)
      expect(welsh_translation_input.declaration_text_cy).to eq(form.declaration_text_cy)
      expect(welsh_translation_input.support_email_cy).to eq(form.support_email_cy)
      expect(welsh_translation_input.support_phone_cy).to eq(form.support_phone_cy)
      expect(welsh_translation_input.support_url_cy).to eq(form.support_url_cy)
      expect(welsh_translation_input.support_url_text_cy).to eq(form.support_url_text_cy)
      expect(welsh_translation_input.privacy_policy_url_cy).to eq(form.privacy_policy_url_cy)
      expect(welsh_translation_input.payment_url_cy).to eq(form.payment_url_cy)
      expect(welsh_translation_input.mark_complete).to eq(form.welsh_completed)
    end
  end
end
