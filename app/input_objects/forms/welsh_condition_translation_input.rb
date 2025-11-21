class Forms::WelshConditionTranslationInput < BaseInput
  include ActionView::Helpers::FormTagHelper
  include ActiveModel::Attributes

  attribute :id
  attribute :exit_page_markdown_cy
  attribute :exit_page_heading_cy

  def submit
    return false if invalid?

    condition.exit_page_markdown_cy = condition_has_exit_page? ? exit_page_markdown_cy : nil
    condition.exit_page_heading_cy = condition_has_exit_page? ? exit_page_heading_cy : nil

    condition.save!
  end

  def assign_condition_values
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
    condition.is_exit_page?
  end

  def condition_has_answer_value?
    condition.answer_value.present?
  end

  def condition_has_exit_page?
    condition.is_exit_page?
  end
end
