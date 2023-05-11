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
    render(PageListComponent::ErrorSummary::View.new(pages:))
  end

  def error_component_with_errors
    routing_conditions_page_1 = [(build :condition, :with_answer_value_missing, id: 1, routing_page_id: 1, check_page_id: 1, goto_page_id: 3)]
    routing_conditions_page_2 = [(build :condition, :with_goto_page_missing, id: 2, routing_page_id: 2, check_page_id: 2, answer_value: "Wales")]

    pages = [(build :page, id: 1, position: 1, question_text: "Enter your name", routing_conditions: routing_conditions_page_1),
             (build :page, id: 2, position: 2, question_text: "What is your pet's phone number?", routing_conditions: routing_conditions_page_2),
             (build :page, id: 3, position: 3, question_text: "How many pets do you own?", routing_conditions: [])]

    render(PageListComponent::ErrorSummary::View.new(pages:))
  end
end
