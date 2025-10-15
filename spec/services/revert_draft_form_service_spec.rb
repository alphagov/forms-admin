require "rails_helper"
# require "helpers/revert_to_live_state_matcher"

RSpec::Matchers.define :be_reverted_to_live_state do
  match do |form|
    # reload the form to get the latest state from the database
    reloaded_form = form.reload

    # the form should be live
    is_live = reloaded_form.live?

    # We convert the form to a form document and compare the content
    # to the live form document content and check they match baring the live_at times
    # this is the closest we can get to saying there is no changes to the form
    document_matches = reloaded_form.as_form_document.except("live_at") == form.live_form_document.content.except("live_at")

    is_live && document_matches
  end
end

describe RevertDraftFormService do
  subject(:revert_draft_to_live_form_service) { described_class.new(form) }

  let(:form) { create(:form, :live_with_draft) }

  delegate :revert_draft_to_live, to: :revert_draft_to_live_form_service

  # we use `freeze_time` to freeze the timestamps of the form and its pages
  # reverting a draft will not keep the timestamps from the live version
  around { |example| freeze_time { example.run } }

  context "when the draft has no changes" do
    it "reverts the form to its live state" do
      revert_draft_to_live
      expect(form).to be_reverted_to_live_state
    end
  end

  context "when a form attribute is changed in the draft" do
    before do
      form.update!(name: "A new draft name")
    end

    it "reverts the attribute change" do
      revert_draft_to_live
      expect(form).to be_reverted_to_live_state
    end
  end

  context "when a page attribute is changed in the draft" do
    before do
      form.pages.first.update!(question_text: "A new draft question text")
    end

    it "reverts the page change" do
      revert_draft_to_live
      expect(form).to be_reverted_to_live_state
    end
  end

  context "when a page is added to the draft" do
    before do
      form.pages.create!(answer_type: "text", question_text: "A new page added to the draft", is_optional: false)
    end

    it "removes the added page" do
      revert_draft_to_live
      expect(form).to be_reverted_to_live_state
    end
  end

  context "when a page is removed from the draft" do
    before do
      form.pages.last.destroy!
    end

    it "re-adds the removed page" do
      revert_draft_to_live
      expect(form).to be_reverted_to_live_state
    end
  end

  context "with routing conditions" do
    let(:form) { create(:form, :ready_for_live, pages_count: 2) }

    before do
      # live version with a routing condition
      form.pages.first.routing_conditions.create!(
        answer_value: "Yes",
        goto_page_id: form.pages.last.id,
        routing_page_id: form.pages.first.id,
      )
      FormDocument.create!(form:, tag: "live", content: form.as_form_document(live_at: form.updated_at))
      form.update!(state: :live_with_draft)
    end

    context "when a routing condition is added to the draft" do
      before do
        form.pages.first.routing_conditions.create!(
          answer_value: "No",
          goto_page_id: form.pages.last.id,
          routing_page_id: form.pages.first.id,
        )
      end

      it "removes the added routing condition" do
        revert_draft_to_live
        expect(form).to be_reverted_to_live_state
      end
    end

    context "when a routing condition is removed from the draft" do
      before do
        form.pages.first.routing_conditions.first.destroy!
      end

      it "re-adds the removed routing condition" do
        revert_draft_to_live
        expect(form).to be_reverted_to_live_state
      end
    end

    context "when a routing condition is changed in the draft" do
      before do
        form.pages.first.routing_conditions.first.update!(answer_value: "Maybe")
      end

      it "reverts the changed routing condition" do
        revert_draft_to_live
        expect(form).to be_reverted_to_live_state
      end
    end
  end
end
