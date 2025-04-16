RSpec.shared_context "with pages with routing" do
  let(:pages) do
    [
      build(
        :page,
        id: 1,
        position: 1,
        next_page: 2,
        question_text: "Question",
      ),
      build(
        :page,
        :with_selection_settings,
        id: 2,
        position: 2,
        next_page: 3,
        question_text: "Branch question (start of a route)",
        selection_options: [{ name: "First branch" }, { name: "Second branch" }],
        routing_conditions: [
          build(
            :condition,
            id: 1,
            answer_value: "Second branch",
            check_page_id: 2,
            goto_page_id: 5,
            routing_page_id: 2,
            exit_page_heading: nil,
            exit_page_markdown: nil,
          ),
        ],
      ),
      build(
        :page,
        id: 3,
        position: 3,
        next_page: 4,
        question_text: "Question in branch 1",
      ),
      build(
        :page,
        id: 4,
        position: 4,
        next_page: 5,
        question_text: "Question at the end of branch 1 (start of a secondary skip)",
        routing_conditions: [
          build(
            :condition,
            id: 2,
            answer_value: nil,
            check_page_id: 2,
            goto_page_id: 8,
            routing_page_id: 4,
            exit_page_heading: nil,
            exit_page_markdown: nil,
          ),
        ],
      ),
      build(
        :page,
        id: 5,
        position: 5,
        next_page: 6,
        question_text: "Question at the start of branch 2 (end of a route)",
      ),
      build(
        :page,
        id: 6,
        position: 6,
        next_page: 7,
        question_text: "Question in branch 2",
      ),
      build(
        :page,
        id: 7,
        position: 7,
        next_page: 8,
        question_text: "Question at the end of branch 2",
      ),
      build(
        :page,
        id: 8,
        position: 8,
        next_page: 9,
        question_text: "Question after a branch route (end of a secondary skip)",
      ),
      build(
        :page,
        id: 9,
        position: 9,
        next_page: 10,
        question_text: "Question",
      ),
      build(
        :page,
        :with_selection_settings,
        id: 10,
        position: 10,
        next_page: 11,
        question_text: "Skip question",
        selection_options: [{ name: "Skip" }, { name: "Don't skip" }],
        routing_conditions: [
          build(
            :condition,
            id: 3,
            answer_value: "Skip",
            check_page_id: 10,
            goto_page_id: 12,
            routing_page_id: 10,
            exit_page_heading: nil,
            exit_page_markdown: nil,
          ),
        ],
      ),
      build(
        :page,
        id: 11,
        position: 11,
        next_page: 12,
        question_text: "Question to be skipped",
      ),
      build(
        :page,
        id: 12,
        position: 12,
        next_page: 13,
        question_text: "Question",
      ),
      build(
        :page,
        :with_selection_settings,
        id: 13,
        position: 13,
        question_text: "Exit page question",
        selection_options: [{ name: "Exit" }, { name: "Don't exit" }],
        routing_conditions: [
          build(
            :condition,
            id: 4,
            answer_value: "Exit",
            check_page_id: 13,
            goto_page_id: nil,
            routing_page_id: 13,
            exit_page_heading: "Exit page heading",
            exit_page_markdown: "Exit page markdown",
          ),
        ],
      ),
    ]
  end

  let(:branch_route_1) do
    page_with_skip_and_secondary_skip.routing_conditions.first
  end

  let(:branch_any_other_answer_route) do
    start_of_a_secondary_skip.routing_conditions.first
  end

  let(:skip_route) do
    page_with_skip_route.routing_conditions.first
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

  let(:page_with_exit_page) do
    pages[12]
  end

  let(:exit_page) do
    page_with_exit_page.routing_conditions.first
  end
end
