class Forms::WelshPageTranslationInput < BaseInput
  include TextInputHelper
  include ActionView::Helpers::FormTagHelper
  include ActiveModel::Attributes

  attr_accessor :condition_translations

  attribute :id
  attribute :question_text_cy
  attribute :hint_text_cy
  attribute :page_heading_cy
  attribute :guidance_markdown_cy

  validate :question_text_cy_present?, on: :mark_complete
  validate :question_text_cy_length, if: -> { question_text_cy.present? }

  validate :hint_text_cy_present?, on: :mark_complete
  validate :hint_text_cy_length, if: -> { hint_text_cy.present? }

  validate :page_heading_cy_present?, on: :mark_complete
  validate :page_heading_cy_length, if: -> { page_heading_cy.present? }

  validate :guidance_markdown_cy_present?, on: :mark_complete
  validate :guidance_markdown_cy_length_and_tags, if: -> { guidance_markdown_cy.present? }

  validate :condition_translations_valid?

  def initialize(attributes = {})
    super
    @condition_translations ||= []
  end

  def submit
    return false if invalid?

    page.question_text_cy = question_text_cy
    page.hint_text_cy = page_has_hint_text? ? hint_text_cy : nil
    page.page_heading_cy = page_has_page_heading_and_guidance_markdown? ? page_heading_cy : nil
    page.guidance_markdown_cy = page_has_page_heading_and_guidance_markdown? ? guidance_markdown_cy : nil

    if condition_translations.present?
      condition_translations.each(&:submit)
    end

    page.save!
  end

  def assign_page_values
    page = Page.find_by(id:)
    return self unless page # Guard clause

    self.question_text_cy = page.question_text_cy
    self.hint_text_cy = page.hint_text_cy
    self.page_heading_cy = page.page_heading_cy
    self.guidance_markdown_cy = page.guidance_markdown_cy
    # self.mark_complete = page.form.try(:welsh_completed)

    self.condition_translations = page.routing_conditions.map do |condition|
      Forms::WelshConditionTranslationInput.new(id: condition.id).assign_condition_values
    end
    self
  end

  # Custom writer for condition translations
  def condition_translations_attributes=(attributes)
    self.condition_translations = attributes.is_a?(Hash) ? attributes.values : attributes
    condition_translations.map! do |condition_attrs|
      Forms::WelshConditionTranslationInput.new(**condition_attrs.symbolize_keys)
    end
  end

  def page
    @page ||= Page.find(id)
    @page
  end

  def form_field_id(attribute)
    field_id(:forms_welsh_page_translation_input, page.id, :page_translations, attribute)
  end

  def page_has_hint_text?
    page.hint_text.present?
  end

  def page_has_page_heading_and_guidance_markdown?
    page.page_heading.present? && page.guidance_markdown.present?
  end

  def question_text_cy_present?
    if question_text_cy.blank?
      errors.add(:question_text_cy, :blank, question_number: page.position, url: "##{form_field_id(:question_text_cy)}")
    end
  end

  def question_text_cy_length
    return if question_text_cy.length <= QuestionTextValidation::QUESTION_TEXT_MAX_LENGTH

    errors.add(:question_text_cy, :too_long, question_number: page.position, count: QuestionTextValidation::QUESTION_TEXT_MAX_LENGTH, url: "##{form_field_id(:question_text_cy)}")
  end

  def hint_text_cy_present?
    if page_has_hint_text? && hint_text_cy.blank?
      errors.add(:hint_text_cy, :blank, question_number: page.position, url: "##{form_field_id(:hint_text_cy)}")
    end
  end

  def hint_text_cy_length
    return if hint_text_cy.length <= 500

    errors.add(:hint_text_cy, :too_long, question_number: page.position, count: 500, url: "##{form_field_id(:hint_text_cy)}")
  end

  def page_heading_cy_present?
    if page_has_page_heading_and_guidance_markdown? && page_heading_cy.blank?
      errors.add(:page_heading_cy, :blank, question_number: page.position, url: "##{form_field_id(:page_heading_cy)}")
    end
  end

  def page_heading_cy_length
    return if page_heading_cy.length <= 250

    errors.add(:page_heading_cy, :too_long, question_number: page.position, count: 250, url: "##{form_field_id(:page_heading_cy)}")
  end

  def guidance_markdown_cy_present?
    if page_has_page_heading_and_guidance_markdown? && guidance_markdown_cy.blank?
      errors.add(:guidance_markdown_cy, :blank, question_number: page.position, url: "##{form_field_id(:guidance_markdown_cy)}")
    end
  end

  def guidance_markdown_cy_length_and_tags
    markdown_validation = GovukFormsMarkdown.validate(guidance_markdown_cy)

    return true if markdown_validation[:errors].empty?

    if markdown_validation[:errors].include?(:too_long)
      errors.add(:guidance_markdown_cy, :too_long, count: "4,999", question_number: page.position, url: "##{form_field_id(:guidance_markdown_cy)}")
    end

    tag_errors = markdown_validation[:errors].excluding(:too_long)
    if tag_errors.any?
      errors.add(:guidance_markdown_cy, :unsupported_markdown_syntax, question_number: page.position, url: "##{form_field_id(:guidance_markdown_cy)}")
    end
  end

  def form_marked_complete?
    mark_complete == "true"
  end

  def condition_translations_valid?
    return if condition_translations.nil?

    condition_translations.each do |condition_translation|
      condition_translation.validate(validation_context)

      errors.merge!(condition_translation.errors)
    end
  end
end
