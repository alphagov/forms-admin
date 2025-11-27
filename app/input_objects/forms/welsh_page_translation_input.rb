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

  validate :question_text_cy_present?
  validate :hint_text_cy_present?
  validate :page_heading_cy_present?
  validate :guidance_markdown_cy_present?

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
    self.question_text_cy = page.question_text_cy
    self.hint_text_cy = page.hint_text_cy
    self.page_heading_cy = page.page_heading_cy
    self.guidance_markdown_cy = page.guidance_markdown_cy

    self
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
    errors.add(:question_text_cy, :blank) if question_text_cy.blank?
  end

  def hint_text_cy_present?
    errors.add(:hint_text_cy, :blank) if page_has_hint_text? && hint_text_cy.blank?
  end

  def page_heading_cy_present?
    errors.add(:page_heading_cy, :blank) if page_has_page_heading_and_guidance_markdown? && page_heading_cy.blank?
  end

  def guidance_markdown_cy_present?
    errors.add(:guidance_markdown_cy, :blank) if page_has_page_heading_and_guidance_markdown? && guidance_markdown_cy.blank?
  end
end
