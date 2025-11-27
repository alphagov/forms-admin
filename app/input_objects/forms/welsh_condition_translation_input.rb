class Forms::WelshConditionTranslationInput < BaseInput
  include ActionView::Helpers::FormTagHelper
  include ActiveModel::Attributes

  attribute :id
  attribute :answer_value_cy
  attribute :exit_page_markdown_cy
  attribute :exit_page_heading_cy

  validate :answer_value_cy_present?
  validate :exit_page_heading_cy_present?
  validate :exit_page_markdown_cy_present?

  def submit
    return false if invalid?

    condition.answer_value_cy = condition_has_answer_value? ? answer_value_cy : nil
    condition.exit_page_markdown_cy = condition_has_exit_page? ? exit_page_markdown_cy : nil
    condition.exit_page_heading_cy = condition_has_exit_page? ? exit_page_heading_cy : nil

    condition.save!
  end

  def assign_condition_values
    self.answer_value_cy = condition.answer_value_cy
    self.exit_page_markdown_cy = condition.exit_page_markdown_cy
    self.exit_page_heading_cy = condition.exit_page_heading_cy

    self
  end

  def condition
    @condition ||= Condition.find(id)
    @condition
  end

  def form_field_id(attribute)
    field_id(:forms_welsh_condition_translation_input, condition.id, :condition_translations, attribute)
  end

  def has_translatable_content?
    condition_has_answer_value? || condition.is_exit_page?
  end

  def condition_has_answer_value?
    condition.answer_value.present?
  end

  def condition_has_exit_page?
    condition.is_exit_page?
  end

  def answer_value_cy_present?
    errors.add(:answer_value_cy, :blank, url: "##{form_field_id(:answer_value_cy)}") if condition_has_answer_value? && answer_value_cy.blank?
  end

  def exit_page_heading_cy_present?
    errors.add(:exit_page_heading_cy, :blank, url: "##{form_field_id(:exit_page_heading_cy)}") if condition_has_exit_page? && exit_page_heading_cy.blank?
  end

  def exit_page_markdown_cy_present?
    errors.add(:exit_page_markdown_cy, :blank, url: "##{form_field_id(:exit_page_markdown_cy)}") if condition_has_exit_page? && exit_page_markdown_cy.blank?
  end
end
