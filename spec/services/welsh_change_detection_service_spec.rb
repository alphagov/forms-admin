require "rails_helper"

RSpec.describe WelshChangeDetectionService do
  describe "#update_welsh?" do
    context "when form does not have Welsh enabled" do
      let(:form) { create(:form, :live, available_languages: %w[en]) }

      it "returns false" do
        expect(described_class.new(form).update_welsh?).to be false
      end
    end

    context "when form has Welsh enabled with no changes" do
      let(:form) { create(:form, :live, available_languages: %w[en cy], what_happens_next_markdown: nil, support_email: nil, support_phone: nil) }

      before do
        form.pages.each { |p| p.update!(question_text_cy: "Welsh #{p.question_text}") }
        FormDocumentSyncService.new(form).synchronize_live_form
      end

      it "returns false" do
        expect(described_class.new(form).update_welsh?).to be false
      end
    end

    context "when form has Welsh enabled with changes" do
      let(:form) { create(:form, :live, available_languages: %w[en cy], what_happens_next_markdown: nil, support_email: nil, support_phone: nil) }

      before do
        form.pages.each { |p| p.update!(question_text_cy: "Welsh #{p.question_text}") }
        FormDocumentSyncService.new(form).synchronize_live_form
        form.pages.create!(question_text: "New question", answer_type: "text", is_optional: false)
        form.save_question_changes!
      end

      it "returns true" do
        expect(described_class.new(form).update_welsh?).to be true
      end
    end
  end

  describe "#changes" do
    context "when form does not have Welsh enabled" do
      let(:form) { create(:form, :live, available_languages: %w[en]) }

      it "returns empty array" do
        expect(described_class.new(form).changes).to eq([])
      end
    end

    context "when Welsh FormDocument does not exist" do
      let(:form) { create(:form, available_languages: %w[en cy]) }

      before do
        FormDocument.where(form_id: form.id, language: "cy").destroy_all
      end

      it "returns no_welsh_document change" do
        expect(described_class.new(form).changes).to eq([{ type: :no_welsh_document }])
      end
    end

    context "when form has Welsh enabled and synced" do
      let(:form) { create(:form, :live, available_languages: %w[en cy], what_happens_next_markdown: nil, support_email: nil, support_phone: nil) }

      before do
        form.pages.each { |p| p.update!(question_text_cy: "Welsh #{p.question_text}") }
        FormDocumentSyncService.new(form).synchronize_live_form
      end

      it "returns empty array when no changes" do
        expect(described_class.new(form).changes).to eq([])
      end
    end

    context "when there are structural changes" do
      let(:form) { create(:form, :live, available_languages: %w[en cy], what_happens_next_markdown: nil, support_email: nil, support_phone: nil) }

      before do
        form.pages.each { |page| page.update!(question_text_cy: "Welsh #{page.question_text}") }
        FormDocumentSyncService.new(form).synchronize_live_form
      end

      context "when there is a new page" do
        before do
          form.pages.create!(question_text: "New question", answer_type: "text", is_optional: false)
          form.save_question_changes!
        end

        it "detects new page" do
          changes = described_class.new(form).changes

          expect(changes).to include(
            hash_including(type: :new_page, page_id: form.pages.last.id),
          )
        end
      end

      context "when page is deleted" do
        let!(:deleted_external_id) { form.pages.first.external_id }

        before do
          form.pages.first.destroy!
          form.save_question_changes!
        end

        it "detects deleted page" do
          changes = described_class.new(form).changes

          expect(changes).to include(
            hash_including(type: :deleted_page, external_id: deleted_external_id),
          )
        end
      end

      context "when there are new form fields" do
        before do
          form.update!(declaration_text: "I declare this is correct")
          form.save_question_changes!
        end

        it "detects new form field" do
          changes = described_class.new(form).changes

          expect(changes).to include(
            hash_including(type: :new_field, field: :declaration_text, scope: :form),
          )
        end
      end

      context "when there are new page fields" do
        let(:page) { form.pages.first }

        before do
          page.update!(hint_text: "Please provide details")
          form.save_question_changes!
        end

        it "detects new page field" do
          changes = described_class.new(form).changes

          expect(changes).to include(
            hash_including(type: :new_field, field: :hint_text, page_id: page.id),
          )
        end
      end

      context "when there are new selection options" do
        let!(:selection_page) do
          create(:page,
                 form:,
                 answer_type: "selection",
                 answer_settings: {
                   "only_one_option" => "true",
                   "selection_options" => [{ "name" => "Yes" }, { "name" => "No" }],
                 })
        end

        before do
          form.reload
          selection_page.update!(answer_settings_cy: {
            "only_one_option" => "true",
            "selection_options" => [{ "name" => "Ydy" }, { "name" => "Nac ydy" }],
          })
          FormDocumentSyncService.new(form).synchronize_live_form

          selection_page.update!(answer_settings: {
            "only_one_option" => "true",
            "selection_options" => [{ "name" => "Yes" }, { "name" => "No" }, { "name" => "Maybe" }],
          })
          form.save_question_changes!
        end

        it "detects new selection option" do
          changes = described_class.new(form).changes

          expect(changes).to include(
            hash_including(type: :new_selection_option, page_id: selection_page.id, option_index: 2, option_name: "Maybe"),
          )
        end
      end

      context "when selection option is removed" do
        let!(:selection_page) do
          create(:page,
                 form:,
                 answer_type: "selection",
                 answer_settings: {
                   "only_one_option" => "true",
                   "selection_options" => [{ "name" => "Yes" }, { "name" => "No" }, { "name" => "Maybe" }],
                 })
        end

        before do
          form.reload
          selection_page.update!(answer_settings_cy: {
            "only_one_option" => "true",
            "selection_options" => [{ "name" => "Ydy" }, { "name" => "Nac ydy" }, { "name" => "Efallai" }],
          })
          FormDocumentSyncService.new(form).synchronize_live_form

          selection_page.update!(answer_settings: {
            "only_one_option" => "true",
            "selection_options" => [{ "name" => "Yes" }, { "name" => "No" }],
          })
          form.save_question_changes!
        end

        it "detects removed selection option" do
          changes = described_class.new(form).changes

          expect(changes).to include(
            hash_including(type: :removed_selection_option, page_id: selection_page.id),
          )
        end
      end

      context "when there is a new routing condition" do
        let!(:selection_page) do
          create(:page,
                 form:,
                 answer_type: "selection",
                 answer_settings: {
                   "only_one_option" => "true",
                   "selection_options" => [{ "name" => "Yes" }, { "name" => "No" }],
                 })
        end
        let!(:target_page) { create(:page, form:) }

        before do
          form.reload
          FormDocumentSyncService.new(form).synchronize_live_form

          selection_page.routing_conditions.create!(
            answer_value: "Yes",
            routing_page: selection_page,
            check_page: selection_page,
            goto_page: target_page,
          )
          form.save_question_changes!
        end

        it "detects new condition" do
          changes = described_class.new(form).changes

          expect(changes).to include(
            hash_including(type: :new_condition, condition_id: selection_page.routing_conditions.first.id),
          )
        end
      end

      context "when a routing condition is deleted" do
        let!(:selection_page) do
          create(:page,
                 form:,
                 answer_type: "selection",
                 answer_settings: {
                   "only_one_option" => "true",
                   "selection_options" => [{ "name" => "Yes" }, { "name" => "No" }],
                 })
        end
        let!(:target_page) { create(:page, form:) }
        let!(:condition) do
          selection_page.routing_conditions.create!(
            answer_value: "Yes",
            routing_page: selection_page,
            check_page: selection_page,
            goto_page: target_page,
          )
        end
        let(:deleted_condition_id) { condition.id }

        before do
          form.reload
          FormDocumentSyncService.new(form).synchronize_live_form

          condition.destroy!
          form.save_question_changes!
        end

        it "detects deleted condition" do
          changes = described_class.new(form).changes

          expect(changes).to include(
            hash_including(type: :deleted_condition, condition_id: deleted_condition_id),
          )
        end
      end
    end

    context "when there is content without translations" do
      let(:form) { create(:form, :live, available_languages: %w[en cy], what_happens_next_markdown: nil, support_email: nil, support_phone: nil) }

      before do
        FormDocumentSyncService.new(form).synchronize_live_form
      end

      context "when there are untranslated page fields" do
        before do
          form.pages.create!(question_text: "New question", answer_type: "text", is_optional: false)
          form.save_question_changes!
        end

        it "detects untranslated question_text" do
          changes = described_class.new(form).changes

          expect(changes).to include(
            hash_including(type: :untranslated_field, field: :question_text, page_id: form.pages.last.id),
          )
        end
      end

      context "when there are untranslated form fields" do
        before do
          form.update!(declaration_text: "I declare this is correct")
          form.save_question_changes!
        end

        it "detects untranslated declaration_text" do
          changes = described_class.new(form).changes

          expect(changes).to include(
            hash_including(type: :untranslated_field, field: :declaration_text, scope: :form),
          )
        end
      end

      context "when there are untranslated selection options" do
        let!(:selection_page) do
          create(:page,
                 form:,
                 answer_type: "selection",
                 answer_settings: {
                   "only_one_option" => "true",
                   "selection_options" => [{ "name" => "Yes" }, { "name" => "No" }],
                 })
        end

        before do
          form.reload
          form.save_question_changes!
        end

        it "detects untranslated selection options" do
          changes = described_class.new(form).changes

          expect(changes).to include(
            hash_including(type: :untranslated_option, page_id: selection_page.id, option_index: 0, option_name: "Yes"),
          )
        end
      end
    end

    context "when checking excluded fields" do
      let(:form) { create(:form, :live, available_languages: %w[en cy]) }

      before do
        form.pages.each { |p| p.update!(question_text_cy: "Welsh #{p.question_text}") }
        FormDocumentSyncService.new(form).synchronize_live_form
        form.save_question_changes!
      end

      it "does not report name as untranslated" do
        changes = described_class.new(form).changes

        expect(changes).not_to include(hash_including(field: :name))
      end

      it "does not report privacy_policy_url as untranslated" do
        changes = described_class.new(form).changes

        expect(changes).not_to include(hash_including(field: :privacy_policy_url))
      end
    end
  end
end
