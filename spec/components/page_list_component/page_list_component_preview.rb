class PageListComponent::PageListComponentPreview < ViewComponent::Preview
  include FactoryBot::Syntax::Methods

  def default
    pages = []
    form = build(:form, id: 0, pages:)
    render(PageListComponent::View.new(pages:, form:))
  end

  def with_pages_and_no_conditions
    pages = [build(:page, id: 1, position: 1, question_text: "Enter your name", routing_conditions: []),
             build(:page, id: 2, position: 2, question_text: "What is your pet's phone number?", routing_conditions: []),
             build(:page, id: 3, position: 3, question_text: "How many pets do you own?", routing_conditions: [])]
    form = build(:form, id: 0, pages:)
    render(PageListComponent::View.new(pages:, form:))
  end

  def with_pages_and_one_condition
    condition = (build :condition, id: 1, routing_page_id: 1, check_page_id: 1, answer_value: "Wales", goto_page_id: 3)
    pages = [build(:page, id: 1, position: 1, question_text: "Enter your name", routing_conditions: [condition]),
             build(:page, id: 2, position: 2, question_text: "What is your pet's phone number?", routing_conditions: []),
             build(:page, id: 3, position: 3, question_text: "How many pets do you own?", routing_conditions: [])]
    form = build(:form, id: 0, pages:)

    # We need to build the records rather than create them so that we don't save them to the database when we view the
    # preview. However, this means that the associations aren't available so we need to manually set the associations
    # after we've built the conditions
    condition.routing_page = pages[0]
    condition.check_page = pages[0]
    condition.goto_page = pages[2]
    condition.form = form

    render(PageListComponent::View.new(pages:, form:))
  end

  def with_pages_and_multiple_conditions
    routing_conditions_1 = [(build :condition, id: 1, routing_page_id: 1, check_page_id: 1, answer_value: "Wales", goto_page_id: 3),
                            (build :condition, id: 2, routing_page_id: 1, check_page_id: 1, answer_value: "England", goto_page_id: 2)]
    routing_conditions_2 = [(build :condition, id: 3, routing_page_id: 2, check_page_id: 2, answer_value: "Wales", goto_page_id: 3),
                            (build :condition, id: 4, routing_page_id: 2, check_page_id: 2, answer_value: "England", goto_page_id: 2)]
    pages = [(build :page, id: 1, position: 1, question_text: "Enter your name", routing_conditions: routing_conditions_1),
             (build :page, id: 2, position: 2, question_text: "What is your pet's phone number?", routing_conditions: routing_conditions_2),
             (build :page, id: 3, position: 3, question_text: "How many pets do you own?", routing_conditions: [])]
    form = build(:form, id: 0, pages:)

    # We need to build the records rather than create them so that we don't save them to the database when we view the
    # preview. However, this means that the associations aren't available so we need to manually set the associations
    # after we've built the conditions
    (routing_conditions_1 + routing_conditions_2).each do |condition|
      condition.routing_page = pages.select { |page| page.id == condition.routing_page_id }.first
      condition.check_page = pages.select { |page| page.id == condition.check_page_id }.first
      condition.goto_page = pages.select { |page| page.id == condition.goto_page_id }.first
      condition.form = form
    end

    render(PageListComponent::View.new(pages:, form:))
  end

  def with_pages_and_conditions_with_errors
    routing_conditions_1 = [(build :condition, id: 1, routing_page_id: 1, check_page_id: 1, goto_page_id: 3),
                            (build :condition, id: 2, routing_page_id: 1, check_page_id: 1, answer_value: "England"),
                            (build :condition, id: 3, routing_page_id: 1, check_page_id: 1),
                            (build :condition, id: 5, routing_page_id: 1, check_page_id: 1, answer_value: "Wales", goto_page_id: 2)]
    routing_conditions_2 = [build :condition, id: 4, routing_page_id: 2, check_page_id: 2, answer_value: "England", goto_page_id: 1]
    pages = [(build :page, id: 1, position: 1, question_text: "Enter your name", routing_conditions: routing_conditions_1),
             (build :page, id: 2, position: 2, question_text: "What is your pet's phone number?", routing_conditions: routing_conditions_2),
             (build :page, id: 3, position: 3, question_text: "How many pets do you own?", routing_conditions: [])]
    form = build(:form, id: 1, pages:)

    # We need to build the records rather than create them so that we don't save them to the database when we view the
    # preview. However, this means that the associations aren't available so we need to manually set the associations
    # after we've built the conditions
    (routing_conditions_1 + routing_conditions_2).each do |condition|
      condition.routing_page = pages.select { |page| page.id == condition.routing_page_id }.first
      condition.check_page = pages.select { |page| page.id == condition.check_page_id }.first
      condition.goto_page = pages.select { |page| page.id == condition.goto_page_id }.first
      condition.form = form
    end

    render(PageListComponent::View.new(pages:, form:))
  end
end
