class Forms::WelshConditionTranslationInput < BaseInput
  include ActionView::Helpers::FormTagHelper
  include ActiveModel::Attributes

  attr_accessor :mark_complete

  attribute :id
  attribute :exit_page_heading_cy
  attribute :exit_page_markdown_cy

  validate :exit_page_heading_cy_present?
  validate :exit_page_heading_cy_length, if: -> { exit_page_heading_cy.present? }

  validate :exit_page_markdown_cy_present?
  validate :exit_page_markdown_cy_length_and_tags, if: -> { exit_page_markdown_cy.present? }

  def submit
    return false if invalid?

    condition.exit_page_markdown_cy = condition_has_exit_page? ? exit_page_markdown_cy : nil
    condition.exit_page_heading_cy = condition_has_exit_page? ? exit_page_heading_cy : nil

    condition.save!
  end

  def assign_condition_values
    self.exit_page_markdown_cy = condition.exit_page_markdown_cy
    self.exit_page_heading_cy = condition.exit_page_heading_cy
    self.mark_complete = condition.routing_page.form.try(:welsh_completed)

    self
  end

  def condition
    @condition ||= Condition.find(id)
    @condition
  end

  def form_field_id(attribute)
    field_id(:forms_welsh_condition_translation_input, condition.id, :condition_translations, attribute)
  end

  def condition_has_exit_page?
    condition.is_exit_page?
  end

  def exit_page_heading_cy_present?
    if form_marked_complete? && condition_has_exit_page? && exit_page_heading_cy.blank?
      errors.add(:exit_page_heading_cy, :blank, question_number: condition.routing_page.position, url: "##{form_field_id(:exit_page_heading_cy)}")
    end
  end

  def exit_page_heading_cy_length
    return if exit_page_heading_cy.length <= 250

    errors.add(:exit_page_heading_cy, :too_long, question_number: condition.routing_page.position, count: 250, url: "##{form_field_id(:exit_page_heading_cy)}")
  end

  def exit_page_markdown_cy_present?
    if form_marked_complete? && condition_has_exit_page? && exit_page_markdown_cy.blank?
      errors.add(:exit_page_markdown_cy, :blank, question_number: condition.routing_page.position, url: "##{form_field_id(:exit_page_markdown_cy)}")
    end
  end

  def exit_page_markdown_cy_length_and_tags
    markdown_validation = GovukFormsMarkdown.validate(exit_page_markdown_cy)

    return true if markdown_validation[:errors].empty?

    if markdown_validation[:errors].include?(:too_long)
      errors.add(:exit_page_markdown_cy, :too_long, count: 4999, question_number: condition.routing_page.position, url: "##{form_field_id(:exit_page_markdown_cy)}")
    end

    tag_errors = markdown_validation[:errors].excluding(:too_long)
    if tag_errors.any?
      errors.add(:exit_page_markdown_cy, :unsupported_markdown_syntax, question_number: condition.routing_page.position, url: "##{form_field_id(:exit_page_markdown_cy)}")
    end
  end

  def form_marked_complete?
    mark_complete == "true"
  end
end
