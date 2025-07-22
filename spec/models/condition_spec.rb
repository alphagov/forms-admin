require "rails_helper"

RSpec.describe Condition, type: :model do
  subject(:condition) { described_class.new }

  describe "factory" do
    it "has a valid factory" do
      condition = create :condition_record
      expect(condition).to be_valid
    end

    it "has a trait with answer value missing" do
      condition = create :condition_record, :with_answer_value_missing
      expect(condition.has_routing_errors).to be true
      expect(condition.validation_errors).to eq [
        { name: "answer_value_doesnt_exist" },
      ]
    end

    it "has a trait with goto page missing" do
      condition = create :condition_record, :with_goto_page_missing
      expect(condition.has_routing_errors).to be true
      expect(condition.validation_errors).to eq [
        { name: "goto_page_doesnt_exist" },
      ]
    end

    it "has a trait with goto page before check page" do
      condition = create :condition_record, :with_goto_page_before_check_page
      expect(condition.has_routing_errors).to be true
      expect(condition.validation_errors).to eq [
        { name: "cannot_have_goto_page_before_routing_page" },
      ]
    end

    it "has a trait with goto page immediately after check page" do
      condition = create :condition_record, :with_goto_page_immediately_after_check_page
      expect(condition.has_routing_errors).to be true
      expect(condition.validation_errors).to eq [
        { name: "cannot_route_to_next_page" },
      ]
    end

    it "has a trait with answer value and goto page missing" do
      condition = create :condition_record, :with_answer_value_and_goto_page_missing
      expect(condition.has_routing_errors).to be true
      expect(condition.validation_errors).to contain_exactly(
        { name: "answer_value_doesnt_exist" },
        { name: "goto_page_doesnt_exist" },
      )
    end
  end

  describe "destroying" do
    subject!(:condition) do
      create :condition_record
    end

    it "deletes the condition" do
      expect {
        condition.destroy
      }.to change(described_class, :count).by(-1)

      expect(condition).to be_destroyed
    end

    context "when there is another condition that depends on this one" do
      subject!(:condition) do
        described_class.create! check_page: start_of_branches, routing_page: start_of_branches, goto_page: start_of_second_branch
      end

      let!(:secondary_skip_condition) do
        described_class.create! check_page: start_of_branches, routing_page: end_of_first_branch, goto_page_id: end_of_branches
      end

      let(:start_of_branches) { create :page_record }
      let(:end_of_first_branch) { create :page_record }
      let(:start_of_second_branch) { create :page_record }
      let(:end_of_branches) { create :page_record }

      it "destroys the other condition" do
        condition.reload

        expect {
          condition.destroy!
        }.to change(described_class, :count).by(-2)

        expect(described_class).not_to exist(secondary_skip_condition.id)
      end
    end
  end

  describe "#is_exit_page?" do
    it "returns false when exit_page_markdown is nil" do
      condition.exit_page_markdown = nil
      expect(condition.is_exit_page?).to be false
    end

    it "returns true when exit_page_markdown is not nil" do
      condition.exit_page_markdown = ""
      expect(condition.is_exit_page?).to be true
    end
  end

  describe "validations" do
    it "validates" do
      page = create :page_record
      condition.routing_page_id = page.id
      expect(condition).to be_valid
    end

    it "requires routing_page_id" do
      expect(condition).to be_invalid
      expect(condition.errors[:routing_page]).to include("must exist")
    end
  end

  describe "#validation_errors" do
    let(:form) { create :form_record }
    let(:routing_page) { create :page_record, form: }
    let(:goto_page) { nil }
    let(:condition) { create :condition_record, routing_page_id: routing_page.id, goto_page_id: nil }

    it "returns array of validation error objects" do
      expect(condition.validation_errors).to eq([{ name: "goto_page_doesnt_exist" }])
    end

    it "calls each validation method" do
      %i[warning_goto_page_doesnt_exist
         warning_answer_doesnt_exist
         warning_routing_to_next_page
         warning_goto_page_before_routing_page ].each do |validation_methods|
        expect(condition).to receive(validation_methods)
      end
      condition.validation_errors
    end

    it "calls warning_goto_page_doesnt_exist" do
      expect(condition).to receive(:warning_goto_page_doesnt_exist)
      condition.validation_errors
    end

    context "when no validation errors" do
      let(:goto_page) { create :page_record, form: }
      let(:condition) { create :condition_record, routing_page_id: routing_page.id, goto_page_id: goto_page.id }

      it "returns empty array if there are no validation errors" do
        expect(condition.validation_errors).to be_empty
      end
    end
  end

  describe "#warning_goto_page_doesnt_exist" do
    let(:form) { create :form_record }
    let(:routing_page) { create :page_record, form: }
    let(:goto_page) { create :page_record, form: }
    let(:condition) { create :condition_record, routing_page_id: routing_page.id, goto_page_id: goto_page.id }

    it "returns nil if goto page exists" do
      expect(condition.warning_goto_page_doesnt_exist).to be_nil
    end

    context "when goto page is null and skip_to_end is true" do
      let(:condition) { create :condition_record, routing_page_id: routing_page.id, goto_page_id: nil, skip_to_end: true }

      it "returns nil" do
        expect(condition.warning_goto_page_doesnt_exist).to be_nil
      end
    end

    context "when goto page has been deleted" do
      let(:condition) { create :condition_record, routing_page_id: routing_page.id, goto_page_id: 999 }

      it "returns object with error short name code" do
        expect(condition.warning_goto_page_doesnt_exist).to eq({ name: "goto_page_doesnt_exist" })
      end
    end

    context "when goto page may belong to another form" do
      let(:goto_page) { create :page_record }

      it "returns object with error short name code" do
        expect(condition.warning_goto_page_doesnt_exist).to eq({ name: "goto_page_doesnt_exist" })
      end
    end

    context "when is_exit_page?" do
      let(:condition) { create :condition_record, routing_page_id: routing_page.id, goto_page_id: nil, exit_page_markdown: "exit page" }

      it "returns nil" do
        expect(condition.warning_goto_page_doesnt_exist).to be_nil
      end
    end
  end

  describe "#warning_answer_doesnt_exist" do
    let(:form) { create :form_record }
    let(:check_page) { create :page_record, :with_selection_settings, form: }
    let(:goto_page) { create :page_record, form: }
    let(:condition) do
      create(
        :condition_record,
        routing_page_id: check_page.id,
        check_page_id: check_page.id,
        goto_page_id: goto_page.id,
        answer_value: check_page.answer_settings["selection_options"].first["name"],
      )
    end

    it "returns nil if answer exists" do
      expect(condition.warning_answer_doesnt_exist).to be_nil
    end

    context "when answer has been deleted from page" do
      it "returns object with error short name code" do
        condition.check_page.answer_settings["selection_options"].shift
        expect(condition.warning_answer_doesnt_exist).to eq({ name: "answer_value_doesnt_exist" })
      end
    end

    context "when answer on the page has been updated" do
      it "returns object with error short name code" do
        condition.check_page.answer_settings["selection_options"].first["name"] = "Option 1.2"
        expect(condition.warning_answer_doesnt_exist).to eq({ name: "answer_value_doesnt_exist" })
      end
    end

    context "when answer_value is 'None of the above" do
      let(:condition) { create :condition_record, routing_page_id: check_page.id, check_page_id: check_page.id, goto_page_id: goto_page.id, answer_value: :none_of_the_above.to_s }
      let(:check_page) { create :page_record, :with_selection_settings, form:, is_optional: }

      context "and routing page has 'None of the above' as an option" do
        let(:is_optional) { true }

        it "returns nil" do
          expect(condition.warning_answer_doesnt_exist).to be_nil
        end
      end

      context "and routing page does not have 'None of the above' as an option" do
        let(:is_optional) { false }

        it "returns object with error short name code" do
          expect(condition.warning_answer_doesnt_exist).to eq({ name: "answer_value_doesnt_exist" })
        end
      end
    end

    context "when condition is a after another condition for a branch route" do
      let(:routing_page) { create :page_record, form: }
      let(:after_condition) do
        create(
          :condition_record,
          answer_value: nil,
          check_page_id: condition.check_page_id,
          routing_page_id: routing_page.id,
          skip_to_end: true,
        )
      end

      it "returns nil" do
        expect(after_condition.warning_answer_doesnt_exist).to be_nil
      end
    end
  end

  describe "#warning_routing_to_next_page" do
    let(:form) { build :form_record, pages: [check_page, current_page, next_page, last_page] }
    let(:check_page) { build :page_record, position: 1 }
    let(:current_page) { build :page_record, position: 2 }
    let(:next_page) { build :page_record, position: 3 }
    let(:last_page) { build :page_record, position: 4 }

    shared_examples "returns no warning" do
      it "returns nil" do
        expect(condition.warning_routing_to_next_page).to be_nil
      end
    end

    shared_examples "returns routing warning" do
      it "returns cannot_route_to_next_page warning" do
        expect(condition.warning_routing_to_next_page).to eq({ name: "cannot_route_to_next_page" })
      end
    end

    context "when routing to a non-adjacent page" do
      let(:condition) do
        create :condition_record,
               routing_page: current_page,
               check_page: check_page,
               goto_page: last_page
      end

      it_behaves_like "returns no warning"
    end

    context "when routing to the next sequential page" do
      let(:condition) do
        create :condition_record,
               routing_page: current_page,
               check_page: check_page,
               goto_page: next_page
      end

      it_behaves_like "returns routing warning"
    end

    context "with nil values" do
      context "when goto_page is nil" do
        let(:condition) do
          create :condition_record,
                 routing_page: current_page,
                 check_page: check_page,
                 goto_page: nil
        end

        it_behaves_like "returns no warning"
      end

      context "when check_page is nil" do
        let(:condition) do
          create :condition_record,
                 routing_page: current_page,
                 check_page: nil,
                 goto_page: next_page
        end

        it_behaves_like "returns no warning"
      end
    end

    context "with skip_to_end functionality" do
      context "when routing from the last page" do
        let(:condition) do
          create :condition_record,
                 routing_page: last_page,
                 check_page: check_page,
                 goto_page: nil,
                 skip_to_end: true
        end

        it_behaves_like "returns routing warning"
      end

      context "when routing from a non-last page" do
        let(:condition) do
          create :condition_record,
                 routing_page: current_page,
                 check_page: check_page,
                 goto_page: nil,
                 skip_to_end: false
        end

        it_behaves_like "returns no warning"
      end
    end

    context "with non-sequential page positions" do
      let(:current_page) { build :page_record, position: 2 }
      let(:next_page) { build :page_record, position: 4 }
      let(:condition) do
        create :condition_record,
               routing_page: current_page,
               check_page: check_page,
               goto_page: next_page
      end

      it_behaves_like "returns no warning"
    end
  end

  describe "#warning_goto_page_before_routing_page" do
    let(:form) { build :form_record, pages: [previous_page, current_page, next_page, last_page] }
    let(:check_page) { build :page_record, position: 1 }
    let(:previous_page) { build :page_record, position: 2 }
    let(:current_page) { build :page_record, position: 3 }
    let(:next_page) { build :page_record, position: 4 }
    let(:last_page) { build :page_record, position: 5 }

    shared_examples "returns no warning" do
      it "returns nil" do
        expect(condition.warning_goto_page_before_routing_page).to be_nil
      end
    end

    shared_examples "returns routing warning" do
      it "returns cannot_have_goto_page_before_routing_page warning" do
        expect(condition.warning_goto_page_before_routing_page).to(
          eq({ name: "cannot_have_goto_page_before_routing_page" }),
        )
      end
    end

    context "when routing to a later page" do
      let(:condition) do
        create :condition_record,
               routing_page: current_page,
               check_page: current_page,
               goto_page: last_page
      end

      it_behaves_like "returns no warning"
    end

    context "when routing to a previous page" do
      let(:condition) do
        create :condition_record,
               routing_page: current_page,
               check_page: current_page,
               goto_page: previous_page
      end

      it_behaves_like "returns routing warning"
    end

    context "with nil values" do
      context "when goto_page is nil" do
        context "with skip_to_end false" do
          let(:condition) do
            create :condition_record,
                   routing_page: current_page,
                   check_page: current_page,
                   goto_page: nil,
                   skip_to_end: false
          end

          it_behaves_like "returns no warning"
        end

        context "with skip_to_end true" do
          let(:condition) do
            create :condition_record,
                   routing_page: current_page,
                   check_page: current_page,
                   goto_page: nil,
                   skip_to_end: true
          end

          it_behaves_like "returns no warning"
        end
      end
    end

    context "when routing to the same position" do
      let(:same_position_page) { build :page_record, position: 3 }
      let(:condition) do
        create :condition_record,
               routing_page: current_page,
               check_page: current_page,
               goto_page: same_position_page
      end

      it_behaves_like "returns routing warning"
    end

    context "with non-sequential page positions" do
      let(:gap_page) { build :page_record, position: 6 }
      let(:condition) do
        create :condition_record,
               routing_page: current_page,
               check_page: current_page,
               goto_page: gap_page
      end

      it_behaves_like "returns no warning"
    end
  end

  describe "#is_check_your_answers?" do
    let(:form) { create :form_record }
    let(:check_page) { create :page_record, :with_selection_settings, form: }
    let(:goto_page) { create :page_record, form: }

    context "when goto page is nil and skip_to_end is false" do
      let(:condition) { create :condition_record, routing_page_id: check_page.id, check_page_id: check_page.id, goto_page_id: nil, skip_to_end: false }

      it "returns nil" do
        expect(condition.is_check_your_answers?).to be false
      end
    end

    context "when goto page is nil and skip_to_end is true" do
      let(:condition) { create :condition_record, routing_page_id: check_page.id, check_page_id: check_page.id, goto_page_id: nil, skip_to_end: true }

      it "returns nil" do
        expect(condition.is_check_your_answers?).to be true
      end
    end

    context "when goto page has a value and skip_to_end is false" do
      let(:condition) { create :condition_record, routing_page_id: check_page.id, check_page_id: check_page.id, goto_page_id: goto_page.id, skip_to_end: false }

      it "returns nil" do
        expect(condition.is_check_your_answers?).to be false
      end
    end

    context "when goto page has a value and skip_to_end is true" do
      let(:condition) { create :condition_record, routing_page_id: check_page.id, check_page_id: check_page.id, goto_page_id: goto_page.id, skip_to_end: true }

      it "returns nil" do
        expect(condition.is_check_your_answers?).to be false
      end
    end
  end

  describe "#has_routing_errors" do
    let(:form) { create :form_record }
    let(:goto_page) { create :page_record, form: }
    let(:goto_page_id) { goto_page.id }
    let(:routing_page) { create :page_record, form: }
    let(:condition) { create :condition_record, routing_page_id: routing_page.id, goto_page_id: }

    context "when there are no validation errors" do
      it "returns false" do
        expect(condition.has_routing_errors).to be false
      end
    end

    context "when there are validation errors" do
      let(:goto_page_id) { nil }

      it "returns true" do
        expect(condition.has_routing_errors).to be true
      end
    end
  end
end
