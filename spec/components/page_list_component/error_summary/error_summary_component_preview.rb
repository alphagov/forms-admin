class PageListComponent::ErrorSummary::ErrorSummaryComponentPreview < ViewComponent::Preview
  include FactoryBot::Syntax::Methods

  def default
    render(PageListComponent::ErrorSummary::View.new(pages: []))
  end

  def error_component_without_errors
    routing_conditions = [(build :condition, id: 1, routing_page_id: 1, check_page_id: 1, answer_value: "Wales", goto_page_id: 3),
                          (build :condition, id: 2, routing_page_id: 1, check_page_id: 1, answer_value: "England", goto_page_id: 2)]
    pages = [(build :page, id: 1, position: 1, question_text: "Enter your name", routing_conditions:),
             (build :page, id: 2, position: 2, question_text: "What is your pet's phone number?", routing_conditions: []),
             (build :page, id: 3, position: 3, question_text: "How many pets do you own?", routing_conditions: [])]
    form = build(:form, id: 0, pages:)

    # We need to build the records rather than create them so that we don't save them to the database when we view the
    # preview. However, this means that the associations aren't available so we need to manually set the associations
    # after we've built the conditions
    routing_conditions.each do |condition|
      condition.routing_page = pages.select { |page| page.id == condition.routing_page_id }.first
      condition.check_page = pages.select { |page| page.id == condition.check_page_id }.first
      condition.goto_page = pages.select { |page| page.id == condition.goto_page_id }.first
      condition.form = form
    end

    render(PageListComponent::ErrorSummary::View.new(pages:))
  end

  def error_component_with_errors
    routing_conditions_page_1 = [(build :condition, id: 1, routing_page_id: 1, check_page_id: 1, goto_page_id: 3)]
    routing_conditions_page_2 = [(build :condition, id: 2, routing_page_id: 2, check_page_id: 2, answer_value: "Wales")]

    pages = [(build :page, id: 1, position: 1, question_text: "Enter your name", routing_conditions: routing_conditions_page_1),
             (build :page, id: 2, position: 2, question_text: "What is your pet's phone number?", routing_conditions: routing_conditions_page_2),
             (build :page, id: 3, position: 3, question_text: "How many pets do you own?", routing_conditions: [])]
    form = build(:form, id: 0, pages:)

    # We need to build the records rather than create them so that we don't save them to the database when we view the
    # preview. However, this means that the associations aren't available so we need to manually set the associations
    # after we've built the conditions
    (routing_conditions_page_1 + routing_conditions_page_2).each do |condition|
      condition.routing_page = pages.select { |page| page.id == condition.routing_page_id }.first
      condition.check_page = pages.select { |page| page.id == condition.check_page_id }.first
      condition.goto_page = pages.select { |page| page.id == condition.goto_page_id }.first
      condition.form = form
    end

    render(PageListComponent::ErrorSummary::View.new(pages:))
  end
end
