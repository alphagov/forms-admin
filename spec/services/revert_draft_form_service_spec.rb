require "rails_helper"

describe RevertDraftFormService do
  def expect_form_state_and_content_to_be_reverted(form, expected_state)
    # reload the form to get the latest state from the database
    reloaded_form = form.reload

    expect(reloaded_form.state).to eq(expected_state.to_s)

    # We convert the form to a form document and compare the content
    # to the live form document content and check they match baring the live_at times
    # this is the closest we can get to saying there is no changes to the form
    form_document = FormDocument.find_by(form_id: form.id, tag: expected_state, language: "en")
    reloaded_form_document_content = form.reload.as_form_document
    expect(reloaded_form_document_content.except("live_at", "steps")).to eq(form_document.content.except("live_at", "steps"))

    # Compare the steps separately so we get a nice diff if the expectation fails
    reloaded_steps = reloaded_form_document_content["steps"].map { |s| s.except("database_id") }
    expected_steps = form_document.content["steps"].map { |s| s.except("database_id") }
    expect(reloaded_steps).to eq(expected_steps)
  end

  # we use `freeze_time` to freeze the timestamps of the form and its pages
  # reverting a draft will not keep the timestamps from the live version
  around { |example| freeze_time { example.run } }

  describe "when using a live form with drafts" do
    subject(:revert_draft_form_service) { described_class.new(live_form) }

    let(:live_form) { create(:form, :live_with_draft) }
    let(:live_tag) { :live }

    def revert_draft(tag)
      revert_draft_form_service.revert_draft_from_form_document(tag)
    end

    context "when migration to use page external IDs not run" do
      before do
        live_form.live_form_document.content["steps"].each do |step|
          step.delete("database_id")
        end
        live_form.live_form_document.save!
      end

      it "raises an error" do
        expect {
          revert_draft(live_tag)
        }.to raise_error(StandardError, "Migration to use page external IDs not run for form #{live_form.id}")
      end
    end

    context "when the draft has no changes" do
      it "reverts a live form to its live state" do
        revert_draft(live_tag)
        expect_form_state_and_content_to_be_reverted(live_form, :live)
      end
    end

    context "when a form attribute is changed in the draft" do
      before do
        live_form.update!(name: "A new draft name")
      end

      it "reverts the attribute change" do
        revert_draft(live_tag)
        expect_form_state_and_content_to_be_reverted(live_form, :live)
      end
    end

    context "when a page attribute is changed in the draft" do
      before do
        live_form.pages.first.update!(question_text: "A new draft question text")
      end

      it "reverts the page change" do
        revert_draft(live_tag)
        expect_form_state_and_content_to_be_reverted(live_form, :live)
      end
    end

    context "when a page is added to the draft" do
      before do
        live_form.pages.create!(answer_type: "text", question_text: "A new page added to the draft", is_optional: false)
      end

      it "removes the added page" do
        revert_draft(live_tag)
        expect_form_state_and_content_to_be_reverted(live_form, :live)
      end
    end

    context "when a page is removed from the draft" do
      before do
        live_form.pages.last.destroy!
      end

      it "re-adds the removed page" do
        revert_draft(live_tag)
        expect_form_state_and_content_to_be_reverted(live_form, :live)
      end
    end

    context "with routing conditions" do
      let(:live_form) { create(:form, :ready_for_live, pages_count: 2) }

      before do
        # live version with a routing condition
        live_form.pages.first.routing_conditions.create!(
          answer_value: "Yes",
          goto_page_id: live_form.pages.last.id,
          routing_page_id: live_form.pages.first.id,
        )
        FormDocument.create!(form: live_form, tag: "live", content: live_form.as_form_document(live_at: live_form.updated_at))
        live_form.update!(state: :live_with_draft)
      end

      context "when a routing condition is added to the draft" do
        before do
          live_form.pages.first.routing_conditions.create!(
            answer_value: "No",
            goto_page_id: live_form.pages.last.id,
            routing_page_id: live_form.pages.first.id,
          )
        end

        it "removes the added routing condition" do
          revert_draft(live_tag)
          expect_form_state_and_content_to_be_reverted(live_form, :live)
        end
      end

      context "when a routing condition is removed from the draft" do
        before do
          live_form.pages.first.routing_conditions.first.destroy!
        end

        it "re-adds the removed routing condition" do
          revert_draft(live_tag)
          expect_form_state_and_content_to_be_reverted(live_form, :live)
        end
      end

      context "when a routing condition is changed in the draft" do
        before do
          live_form.pages.first.routing_conditions.first.update!(answer_value: "Maybe")
        end

        it "reverts the changed routing condition" do
          revert_draft(live_tag)
          expect_form_state_and_content_to_be_reverted(live_form, :live)
        end
      end
    end
  end

  describe "when using an archived form with drafts" do
    subject(:revert_draft_form_service) { described_class.new(archived_form) }

    let(:archived_form) { create(:form, :archived_with_draft) }
    let(:archived_tag) { :archived }

    def revert_draft(tag)
      revert_draft_form_service.revert_draft_from_form_document(tag)
    end

    context "when the draft has no changes" do
      it "reverts an archived form to its archived state" do
        revert_draft(archived_tag)
        expect_form_state_and_content_to_be_reverted(archived_form, :archived)
      end
    end

    context "when a form attribute is changed in the draft" do
      before do
        archived_form.update!(name: "A new draft name")
      end

      it "reverts the attribute change" do
        revert_draft(archived_tag)
        expect_form_state_and_content_to_be_reverted(archived_form, :archived)
      end
    end

    context "when a page attribute is changed in the draft" do
      before do
        archived_form.pages.first.update!(question_text: "A new draft question text")
      end

      it "reverts the page change" do
        revert_draft(archived_tag)
        expect_form_state_and_content_to_be_reverted(archived_form, :archived)
      end
    end

    context "when a page is added to the draft" do
      before do
        archived_form.pages.create!(answer_type: "text", question_text: "A new page added to the draft", is_optional: false)
      end

      it "removes the added page" do
        revert_draft(archived_tag)
        expect_form_state_and_content_to_be_reverted(archived_form, :archived)
      end
    end

    context "when a page is removed from the draft" do
      before do
        archived_form.pages.last.destroy!
      end

      it "re-adds the removed page" do
        revert_draft(archived_tag)
        expect_form_state_and_content_to_be_reverted(archived_form, :archived)
      end
    end

    context "with routing conditions" do
      let(:archived_form) { create(:form, :ready_for_live, pages_count: 2) }

      before do
        # archived version with a routing condition
        archived_form.pages.first.routing_conditions.create!(
          answer_value: "Yes",
          goto_page_id: archived_form.pages.last.id,
          routing_page_id: archived_form.pages.first.id,
        )
        FormDocument.create!(form: archived_form, tag: "archived", content: archived_form.as_form_document(live_at: archived_form.updated_at))
        archived_form.update!(state: :archived_with_draft)
      end

      context "when a routing condition is added to the draft" do
        before do
          archived_form.pages.first.routing_conditions.create!(
            answer_value: "No",
            goto_page_id: archived_form.pages.last.id,
            routing_page_id: archived_form.pages.first.id,
          )
        end

        it "removes the added routing condition" do
          revert_draft(archived_tag)
          expect_form_state_and_content_to_be_reverted(archived_form, :archived)
        end
      end

      context "when a routing condition is removed from the draft" do
        before do
          archived_form.pages.first.routing_conditions.first.destroy!
        end

        it "re-adds the removed routing condition" do
          revert_draft(archived_tag)
          expect_form_state_and_content_to_be_reverted(archived_form, :archived)
        end
      end

      context "when a routing condition is changed in the draft" do
        before do
          archived_form.pages.first.routing_conditions.first.update!(answer_value: "Maybe")
        end

        it "reverts the changed routing condition" do
          revert_draft(archived_tag)
          expect_form_state_and_content_to_be_reverted(archived_form, :archived)
        end
      end
    end
  end
end
