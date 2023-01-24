# frozen_string_literal: true

require "govuk/components"
class SummaryCardComponent::ViewPreview < ViewComponent::Preview
  def with_no_action_links
    render(SummaryCardComponent::View.new(title: "2. How old are you?", rows: [
      { key: "Hint", value: "Enter your date of birth" },
      { key: "Answer type", value: "Date" },
      { key: "Input type", value: "Date of birth" },
    ]))
  end

  def with_hint_text_in_title
    render(SummaryCardComponent::View.new(title: "How many balls can you juggle with?", rows: [
      { key: "First names", value: "Mike" },
      { key: "Middle names", value: "Larson" },
      { key: "Last name", value: "Doyle" },
    ]))
  end

  def with_question_numbers
    render(SummaryCardComponent::View.new(title: "2. How old are you?", rows: [
      { key: "Hint", value: "Enter your date of birth" },
      { key: "Answer type", value: "Date" },
      { key: "Input type", value: "Date of birth" },
    ]))
  end

  def with_action_links
    render(SummaryCardComponent::View.new(title: "Personal Details", rows: [
      {
        key: "First names",
        value: "Mike",
        action_href: "#mike",
        action_text: "Change",
        action_visually_hidden_text: "first names",
      },
      {
        key: "Middle names",
        value: "Larson",
      },
      {
        key: "Last name",
        value: "Doyle",
        action_href: "http://example.com",
        action_text: "Delete",
        action_visually_hidden_text: "last name",
      },
    ]))
  end
end
