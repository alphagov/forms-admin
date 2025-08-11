RSpec.shared_context "with pages with routing" do
  let(:pages) do
    pages_with_routing
  end

  let(:pages_with_routing) do
    pages = [
      create(
        :page,
        question_text: "Question",
      ),
      create(
        :page,
        :with_selection_settings,
        question_text: "Branch question (start of a route)",
        selection_options: [{ name: "First branch" }, { name: "Second branch" }],
      ),
      create(
        :page,
        question_text: "Question in branch 1",
      ),
      create(
        :page,
        question_text: "Question at the end of branch 1 (start of a secondary skip)",
      ),
      create(
        :page,
        question_text: "Question at the start of branch 2 (end of a route)",
      ),
      create(
        :page,
        question_text: "Question in branch 2",
      ),
      create(
        :page,
        question_text: "Question at the end of branch 2",
      ),
      create(
        :page,
        question_text: "Question after a branch route (end of a secondary skip)",
      ),
      create(
        :page,
        question_text: "Question",
      ),
      create(
        :page,
        :with_selection_settings,
        question_text: "Skip question",
        selection_options: [{ name: "Skip" }, { name: "Don't skip" }],
      ),
      create(
        :page,
        question_text: "Question to be skipped",
      ),
      create(
        :page,
        question_text: "Question",
      ),
      create(
        :page,
        :with_selection_settings,
        question_text: "Exit page question",
        selection_options: [{ name: "Exit" }, { name: "Don't exit" }],
      ),
    ]

    # Create conditions separately
    create(
      :condition,
      answer_value: "Second branch",
      check_page_id: pages[1].id,
      goto_page_id: pages[4].id,
      routing_page_id: pages[1].id,
      exit_page_heading: nil,
      exit_page_markdown: nil,
    )

    create(
      :condition,
      answer_value: nil,
      check_page_id: pages[1].id,
      goto_page_id: pages[7].id,
      routing_page_id: pages[3].id,
      exit_page_heading: nil,
      exit_page_markdown: nil,
    )

    create(
      :condition,
      answer_value: "Skip",
      check_page_id: pages[9].id,
      goto_page_id: pages[11].id,
      routing_page_id: pages[9].id,
      exit_page_heading: nil,
      exit_page_markdown: nil,
    )

    create(
      :condition,
      answer_value: "Exit",
      check_page_id: pages[12].id,
      goto_page_id: nil,
      routing_page_id: pages[12].id,
      exit_page_heading: "Exit page heading",
      exit_page_markdown: "Exit page markdown",
    )

    pages.each(&:reload)
    pages
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
    pages_with_routing[0]
  end

  let(:page_with_skip_and_secondary_skip) do
    pages_with_routing[1]
  end

  let(:start_of_a_secondary_skip) do
    pages_with_routing[3]
  end

  let(:end_of_a_secondary_skip) do
    pages_with_routing[7]
  end

  let(:page_with_skip_route) do
    pages_with_routing[9]
  end

  let(:page_with_exit_page) do
    pages_with_routing[12]
  end

  let(:exit_page) do
    page_with_exit_page.routing_conditions.first
  end
end
