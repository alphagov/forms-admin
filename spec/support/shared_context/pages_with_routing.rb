RSpec.shared_context "with pages with routing" do
  let(:pages) do
    [
      build(
        :page,
        id: 1,
        question_text: "Question",
      ),
      build(
        :page,
        :with_selection_settings,
        id: 2,
        question_text: "Branch question (start of a route)",
        selection_options: [{ name: "First branch" }, { name: "Second branch" }],
        routing_conditions: [
          build(
            :condition,
            answer_value: "Second branch",
            check_page_id: 2,
            goto_page_id: 5,
            routing_page_id: 2,
          ),
        ],
      ),
      build(
        :page,
        id: 3,
        question_text: "Question in branch 1",
      ),
      build(
        :page,
        id: 4,
        question_text: "Question at the end of branch 1 (start of a secondary skip)",
        routing_conditions: [
          build(
            :condition,
            answer_value: nil,
            check_page_id: 2,
            goto_page_id: 8,
            routing_page_id: 4,
          ),
        ],
      ),
      build(
        :page,
        id: 5,
        question_text: "Question at the start of branch 2 (end of a route)",
      ),
      build(
        :page,
        id: 6,
        question_text: "Question in branch 2",
      ),
      build(
        :page,
        id: 7,
        question_text: "Question at the end of branch 2",
      ),
      build(
        :page,
        id: 8,
        question_text: "Question after a branch route (end of a secondary skip)",
      ),
      build(
        :page,
        id: 9,
        question_text: "Question",
      ),
      build(
        :page,
        :with_selection_settings,
        id: 10,
        question_text: "Skip question",
        selection_options: [{ name: "Skip" }, { name: "Don't skip" }],
        routing_conditions: [
          build(
            :condition,
            answer_value: "Skip",
            check_page_id: 10,
            goto_page_id: 12,
            routing_page_id: 10,
          ),
        ],
      ),
      build(
        :page,
        id: 11,
        question_text: "Question to be skipped",
      ),
      build(
        :page,
        id: 12,
        question_text: "Question",
      ),
    ]
  end

  let(:page_with_no_routes) do
    pages[0]
  end

  let(:page_with_skip_and_secondary_skip) do
    pages[1]
  end

  let(:start_of_a_secondary_skip) do
    pages[3]
  end

  let(:end_of_a_secondary_skip) do
    pages[7]
  end

  let(:page_with_skip_route) do
    pages[9]
  end
end
