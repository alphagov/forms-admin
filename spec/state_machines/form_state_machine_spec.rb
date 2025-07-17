require "rails_helper"

class FakeForm < Form
  include FormStateMachine
end

RSpec.describe FormStateMachine do
  let(:form) { FakeForm.new }

  it "has a default state of 'draft'" do
    expect(form).to have_state(:draft)
  end

  describe ".delete_form event" do
    it "does not transition if form is not a draft" do
      expect(form).not_to transition_from(:live).to(:deleted).on_event(:delete_form)
    end

    context "when form is draft" do
      let(:form) { FakeForm.new(state: :draft) }

      it "transitions to deleted stated and is destroyed" do
        expect(form).to receive(:destroy!)
        expect(form).to transition_from(:draft).to(:deleted).on_event(:delete_form)
      end
    end
  end

  describe ".make_live" do
    context "when form is draft" do
      let(:form) { FakeForm.new(state: :draft) }

      it "does not transition to live state by default" do
        expect(form).not_to transition_from(:draft).to(:live).on_event(:make_live)
      end

      context "when all sections are completed" do
        it_behaves_like "transition to live state", FakeForm, :draft
      end
    end

    context "when form is live_with_draft" do
      let(:form) { FakeForm.new(state: :live_with_draft) }

      it "does not transition to live state by default" do
        expect(form).not_to transition_from(:live_with_draft).to(:live).on_event(:make_live)
      end

      context "when all sections are completed" do
        it_behaves_like "transition to live state", FakeForm, :live_with_draft
      end
    end

    context "when form is archived" do
      let(:form) { FakeForm.new(state: :archived) }

      it "does not transition to live state by default" do
        expect(form).not_to transition_from(:archived).to(:live).on_event(:make_live)
      end

      context "when all sections are completed" do
        it_behaves_like "transition to live state", FakeForm, :archived
      end
    end

    context "when form is archived_with_draft" do
      let(:form) { FakeForm.new(state: :archived_with_draft) }

      it "does not transition to live state by default" do
        expect(form).not_to transition_from(:archived_with_draft).to(:live).on_event(:make_live)
      end

      context "when all sections are completed" do
        it_behaves_like "transition to live state", FakeForm, :archived_with_draft
      end
    end
  end

  describe ".create_draft_from_live_form" do
    let(:form) { FakeForm.new(state: :live) }

    it "transitions to live_with_draft if form is live" do
      allow(form).to receive(:update!)
      expect(form).to transition_from(:live).to(:live_with_draft).on_event(:create_draft_from_live_form)
    end

    context "when form is draft" do
      let(:form) { FakeForm.new(state: :draft) }

      it "does not transition to live_with_draft" do
        expect(form).not_to transition_from(:draft).to(:live_with_draft).on_event(:create_draft_from_live_form)
      end
    end
  end

  describe ".create_draft_from_archived_form" do
    let(:form) { FakeForm.new(state: :archived) }

    before do
      allow(form).to receive(:update!)
    end

    it "transitions to archived_with_draft" do
      expect(form).to transition_from(:archived).to(:archived_with_draft).on_event(:create_draft_from_archived_form)
    end

    context "when form is draft" do
      let(:form) { FakeForm.new(state: :draft) }

      it "does not transition to live_with_draft" do
        expect(form).not_to transition_from(:draft).to(:archived_with_draft).on_event(:create_draft_from_archived_form)
      end
    end
  end

  describe ".archive_live_form" do
    context "when the form is draft" do
      let(:form) { FakeForm.new(state: :draft) }

      it "does not transition to archived" do
        expect(form).not_to transition_from(:draft).to(:archived).on_event(:archive_live_form)
      end
    end

    context "when the form is live" do
      let(:form) { FakeForm.new(state: :live) }

      it "transitions to archived" do
        expect(form).to transition_from(:live).to(:archived).on_event(:archive_live_form)
      end
    end

    context "when form is live_with_draft" do
      let(:form) { FakeForm.new(state: :live_with_draft) }

      it "transitions to archived_with_draft" do
        expect(form).to transition_from(:live_with_draft).to(:archived_with_draft).on_event(:archive_live_form)
      end
    end
  end
end
