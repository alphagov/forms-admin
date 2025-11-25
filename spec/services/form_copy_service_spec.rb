require "rails_helper"

RSpec.describe FormCopyService do
  let(:group) { create(:group) }
  let(:source_form) { create(:form, :live_with_draft) }
  let(:source_form_document) { FormDocument.find_by(form_id: source_form.id) }
  let(:logged_in_user) { create(:user) }
  let(:copied_form) { described_class.new(source_form, logged_in_user).copy(tag: "live") }

  before do
    GroupForm.create!(form: source_form, group: group)
  end

  describe "#copy" do
    it "creates a new form" do
      expect(copied_form).to be_a(Form)
      expect(copied_form).to be_persisted
      expect(copied_form.id).not_to eq(source_form.id)
    end

    it "copies and updates the name of the copy" do
      expect(copied_form.name).to eq("Copy of #{source_form.name}")
    end

    it "copies the language from the source form document" do
      expect(copied_form.draft_form_document.language).to eq("en")
    end

    it "associates the draft form document with the new form" do
      expect(copied_form.draft_form_document.form).to eq(copied_form)
    end

    it "has different created_at and updated_at timestamps from the source form" do
      expect(copied_form.created_at).not_to be_nil
      expect(copied_form.created_at).not_to eq(source_form.created_at)

      expect(copied_form.updated_at).not_to be_nil
      expect(copied_form.updated_at).not_to eq(source_form.updated_at)
    end

    context "when source form has completed tasks" do
      before do
        source_form.update!(
          question_section_completed: true,
          declaration_section_completed: true,
          share_preview_completed: true,
          welsh_completed: true,
        )
      end

      it "resets all task completion flags to unstarted" do
        expect(source_form.question_section_completed).to be true
        expect(source_form.declaration_section_completed).to be true
        expect(source_form.share_preview_completed).to be true
        expect(source_form.welsh_completed).to be true

        expect(copied_form.question_section_completed).to be false
        expect(copied_form.declaration_section_completed).to be false
        expect(copied_form.share_preview_completed).to be false
        expect(copied_form.welsh_completed).to be false
      end
    end

    context "when source form has pages" do
      let(:source_form) { create(:form, :live_with_draft, :with_pages, pages_count: 3) }

      it "copies all pages to the new form" do
        expect(copied_form.pages.count).to be > 0
        expect(copied_form.pages.count).to eq(source_form.pages.count)
      end

      it "creates new page records with different IDs" do
        source_page_ids = source_form.pages.pluck(:id)
        copied_page_ids = copied_form.pages.pluck(:id)

        expect(copied_page_ids).not_to be_blank
        expect(copied_page_ids).not_to include(*source_page_ids)
      end

      it "copies page attributes" do
        source_page = source_form.pages.first
        copied_page = copied_form.pages.first

        expect(copied_page.question_text).to eq(source_page.question_text)
        expect(copied_page.answer_type).to eq(source_page.answer_type)
        expect(copied_page.is_optional).to eq(source_page.is_optional)
      end

      it "maintains page positions" do
        source_positions = source_form.pages.pluck(:position)
        copied_positions = copied_form.pages.pluck(:position)

        expect(copied_positions).to eq(source_positions)
      end

      it "has different created_at timestamps for pages" do
        source_page = source_form.pages.first
        copied_page = copied_form.pages.first

        expect(copied_page.created_at).not_to be_nil
        expect(copied_page.created_at).not_to eq(source_page.created_at)
      end

      it "has the same number of steps as the source form has pages in the draft FormDocument" do
        expect(copied_form.draft_form_document.content["steps"].count).to eq(source_form.pages.count)
      end
    end

    context "when source form has pages with routing conditions" do
      let(:source_form) { create(:form, :live_with_draft, :ready_for_routing, pages_count: 3) }

      before do
        create(:condition,
               form: source_form,
               routing_page: source_form.pages.first,
               check_page: source_form.pages.first,
               goto_page: source_form.pages.last,
               answer_value: "Yes")
        source_form.reload

        # Update the live form document to include the pages and conditions
        source_form.live_form_document.update!(content: source_form.as_form_document)
      end

      it "copies routing conditions to the new form" do
        source_conditions_count = source_form.pages.first.routing_conditions.count
        copied_conditions_count = copied_form.pages.first.routing_conditions.count

        expect(copied_conditions_count).to be > 0
        expect(copied_conditions_count).to eq(source_conditions_count)
      end

      it "creates new condition records with different IDs" do
        source_condition_ids = source_form.conditions.pluck(:id)
        copied_condition_ids = copied_form.conditions.pluck(:id)

        expect(copied_condition_ids).not_to be_blank
        expect(copied_condition_ids).not_to include(*source_condition_ids)
      end

      it "copies condition attributes" do
        source_condition = source_form.pages.first.routing_conditions.first
        copied_condition = copied_form.pages.first.routing_conditions.first

        expect(copied_condition.answer_value).to eq(source_condition.answer_value)
        expect(copied_condition.skip_to_end).to eq(source_condition.skip_to_end)
      end

      it "maintains correct page associations for conditions" do
        copied_condition = copied_form.pages.first.routing_conditions.first

        expect(copied_condition.routing_page).to eq(copied_form.pages.first)
        expect(copied_condition.check_page).to eq(copied_form.pages.first)
        expect(copied_condition.goto_page).to eq(copied_form.pages.last)
      end
    end

    context "when source form has pages with exit page conditions" do
      let(:source_form) { create(:form, :live_with_draft, :ready_for_routing, pages_count: 2) }
      let!(:exit_condition) do
        create(:condition, :with_exit_page,
               form: source_form,
               routing_page: source_form.pages.first,
               check_page: source_form.pages.first,
               answer_value: "No")
      end

      before do
        source_form.reload

        # Update the live form document to include the pages and conditions
        source_form.live_form_document.update!(content: source_form.as_form_document)
      end

      it "copies exit page conditions" do
        copied_condition = copied_form.pages.first.routing_conditions.first

        expect(copied_condition.exit_page_heading).to eq(exit_condition.exit_page_heading)
        expect(copied_condition.exit_page_markdown).to eq(exit_condition.exit_page_markdown)
      end

      it "does not associate with a goto_page for exit conditions" do
        copied_condition = copied_form.pages.first.routing_conditions.first

        expect(copied_condition.goto_page).to be_nil
      end
    end

    context "when copying from a draft form document" do
      let(:source_form_document) { create(:form_document, :draft, form: source_form) }

      it "creates a draft form document for the new form" do
        expect(copied_form.draft_form_document.tag).to eq("draft")
      end
    end

    context "when copying from an live form document" do
      let(:source_form_document) { create(:form_document, :live, form: source_form) }

      it "creates a draft form document for the new form" do
        expect(copied_form.state).to eq("draft")
      end
    end

    context "when copying from an archived form document" do
      let(:source_form_document) { create(:form_document, :archived, form: source_form) }

      it "creates a draft form document for the new form" do
        expect(copied_form.state).to eq("draft")
      end
    end

    context "when source form is in a group" do
      let(:group) { create(:group) }
      let(:source_form) { create(:form, :live_with_draft) }

      it "places the copied form in the same group as the original form" do
        expect(copied_form.group).to eq(source_form.group)
        expect(copied_form.group).to eq(group)
      end
    end
  end
end
