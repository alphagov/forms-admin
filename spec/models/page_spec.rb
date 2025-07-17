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
end
