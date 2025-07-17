require "rails_helper"

RSpec.describe Page, type: :model do
  subject(:page) { create :page_record, :with_selections_settings, form:, routing_conditions:, check_conditions: }

  let(:form) { create :form_record }
  let(:routing_conditions) { [] }
  let(:check_conditions) { [] }

  it "has a valid factory" do
    page = create :page_record
    expect(page).to be_valid
  end

  describe "associations" do
    let(:form) { create :form_record }
    let(:page) { create :page_record, form: }

    context "when it has a routing condition" do
      let!(:condition) { page.routing_conditions.create! }

      it "deletes the condition if it is deleted" do
        page.destroy!

        expect(condition).to be_destroyed
      end
    end

    context "when it has a check condition" do
      let(:routing_page) { create :page_record, form: }
      let!(:condition) { page.check_conditions.create! routing_page: }

      it "deletes the condition if it is deleted" do
        page.destroy!

        expect(condition).to be_destroyed
      end
    end

    context "when it has a go to condition" do
      let(:routing_page) { create :page_record, form: }
      let!(:condition) { page.goto_conditions.create! routing_page: }

      it "removes association from the condition if it is deleted" do
        page.destroy!

        expect(condition).to be_destroyed
        expect(condition.goto_page).to be_nil
      end

      context "and the routing page has a secondary skip condition" do
        let(:end_of_first_branch) { create :page_record, form: }
        let!(:condition) { page.goto_conditions.create! routing_page:, check_page: routing_page }
        let!(:secondary_skip_condition) { routing_page.check_conditions.create! routing_page: end_of_first_branch, skip_to_end: true }

        it "deletes the secondary skip condition if it is deleted" do
          expect {
            page.destroy!
          }.to change(Condition, :count).by(-2)

          expect(condition).to be_destroyed
          expect(Condition).not_to exist(secondary_skip_condition.id)
        end
      end

      context "and the routing page has other routing conditions" do
        let!(:condition) { page.goto_conditions.create! routing_page:, check_page: routing_page }
        let!(:other_condition) { routing_page.routing_conditions.create! routing_page:, check_page: routing_page, skip_to_end: true }

        it "does not deletes the other conditions if it is deleted" do
          expect {
            page.destroy!
          }.to change(Condition, :count).by(-1)

          expect(condition).to be_destroyed
          expect(Condition).to exist(other_condition.id)
        end
      end
    end

    context "when the form has a branching route with skip and secondary skip" do
      let(:branch_question) { create :page_record, form: }
      let(:end_of_first_branch) { create :page_record, form: }
      let(:start_of_second_branch) { create :page_record, form: }
      let(:end_of_branches) { create :page_record, form: }

      let!(:skip_condition) do
        create :condition_record, routing_page: branch_question, check_page: branch_question, goto_page: start_of_second_branch
      end
      let!(:secondary_skip_condition) do
        create :condition_record, routing_page: end_of_first_branch, check_page: branch_question, goto_page: end_of_branches
      end

      before do
        branch_question.reload
        end_of_first_branch.reload
        start_of_second_branch.reload
        end_of_branches.reload
      end

      context "and the branch question has been deleted" do
        it "deletes all the conditions" do
          expect {
            branch_question.destroy!
          }.to change(Condition, :count).from(2).to(0)

          expect(Condition).not_to exist(skip_condition.id)
          expect(Condition).not_to exist(secondary_skip_condition.id)
        end
      end

      context "and the question at the start of the second branch has been deleted" do
        it "deletes all the conditions" do
          expect {
            start_of_second_branch.destroy!
          }.to change(Condition, :count).from(2).to(0)

          expect(Condition).not_to exist(skip_condition.id)
          expect(Condition).not_to exist(secondary_skip_condition.id)
        end
      end

      context "and the question at the end of the branches has been deleted" do
        it "deletes the secondary skip condition" do
          expect {
            end_of_branches.destroy!
          }.to change(Condition, :count).from(2).to(1)

          expect(Condition).to exist(skip_condition.id)
          expect(Condition).not_to exist(secondary_skip_condition.id)
        end
      end

      context "and the question at the end of the first branch has been deleted" do
        it "deletes the secondary skip condition" do
          expect {
            end_of_first_branch.destroy!
          }.to change(Condition, :count).from(2).to(1)

          expect(Condition).to exist(skip_condition.id)
          expect(Condition).not_to exist(secondary_skip_condition.id)
        end
      end
    end
  end

  describe "#destroy_and_update_form!" do
    let(:page) { create :page_record }
    let(:form) { page.form }

    it "sets form.question_section_completed to false" do
      form.update!(question_section_completed: true)

      page.destroy_and_update_form!
      expect(form.question_section_completed).to be false
    end
  end

  describe "#save_and_update_form" do
    it "sets form.question_section_completed to false" do
      page.question_text = "Edited question"
      page.save_and_update_form
      expect(form.question_section_completed).to be false
    end

    context "when the form is live" do
      let(:form) { create(:form_record, :live) }

      it "updates the form state to live_with_draft" do
        page.question_text = "Edited question"
        page.save_and_update_form
        expect(form.state).to eq("live_with_draft")
      end
    end

    context "when the form is archived" do
      let(:form) { create(:form_record, :archived) }

      it "updates the form state to archived_with_draft" do
        page.question_text = "Edited question"
        page.save_and_update_form
        expect(form.state).to eq("archived_with_draft")
      end
    end

    context "when page has routing conditions" do
      let(:routing_conditions) { [(create :condition_record)] }
      let(:check_conditions) { routing_conditions }

      it "does not delete existing conditions" do
        page.save_and_update_form
        expect(page.reload.routing_conditions.to_a).to eq(routing_conditions)
        expect(page.reload.check_conditions.to_a).to eq(check_conditions)
      end

      context "when answer type is updated to one doesn't support routing" do
        it "deletes any conditions" do
          page.answer_type = "number"
          page.save_and_update_form
          expect(page.reload.check_conditions).to be_empty
        end
      end

      context "when the page is saved without changing the answer type" do
        it "does not delete the conditions" do
          page.question_text = "test"
          page.save_and_update_form
          expect(page.reload.check_conditions).not_to be_empty
        end
      end

      context "when the answer settings no longer restrict to only one option" do
        it "deletes any conditions" do
          page.answer_settings["only_one_option"] = "0"
          page.save_and_update_form
          expect(page.reload.check_conditions).to be_empty
        end
      end

      context "when the answer settings change while still restricting to only one option" do
        it "does not delete any conditions" do
          page.answer_settings["selection_options"].first["name"] = "New option name"
          page.save_and_update_form
          expect(page.reload.check_conditions).not_to be_empty
        end
      end
    end
  end

  describe "#has_routing_errors" do
    subject(:page) { build :page_record, :with_selections_settings, routing_conditions: [condition] }

    let(:condition) { build :condition_record }
    let(:has_routing_errors) { false }

    before do
      allow(condition).to receive(:has_routing_errors).and_return(has_routing_errors)
    end

    context "when there are no validation errors" do
      it "returns false" do
        expect(page.has_routing_errors).to be false
      end
    end

    context "when there are validation errors" do
      let(:has_routing_errors) { true }

      it "returns true" do
        expect(page.has_routing_errors).to be true
      end
    end
  end
end
