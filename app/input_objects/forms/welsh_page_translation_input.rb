class Forms::WelshPageTranslationInput < BaseInput
  include TextInputHelper
  include ActionView::Helpers::FormTagHelper
  include ActiveModel::Attributes

  attribute :id
  attribute :question_text_cy
  attribute :hint_text_cy
  attribute :page_heading_cy
  attribute :guidance_markdown_cy
  attribute :selection_options_cy, default: []

  def submit
    return false if invalid?

    page.question_text_cy = question_text_cy
    page.hint_text_cy = page_has_hint_text? ? hint_text_cy : nil
    page.page_heading_cy = page_has_page_heading_and_guidance_markdown? ? page_heading_cy : nil
    page.guidance_markdown_cy = page_has_page_heading_and_guidance_markdown? ? guidance_markdown_cy : nil

    if page_has_selection_options?
      welsh_answer_settings = page.answer_settings.dup
      welsh_answer_settings.selection_options = selection_options_cy
      page.answer_settings_cy = welsh_answer_settings
    end

    page.save!
  end

  def assign_page_values
    self.question_text_cy = page.question_text_cy
    self.hint_text_cy = page.hint_text_cy
    self.page_heading_cy = page.page_heading_cy
    self.guidance_markdown_cy = page.guidance_markdown_cy

    # If our welsh translations don't have answer_settings, we need to copy
    # across the english ones and reset any text
    if page.answer_settings && page.answer_settings_cy.blank?
      # Use as_json to get a hash. It's a possibly nested DataStruct and
      # deep_dup or dup doesn't work
      answer_settings_cloned = page.answer_settings.as_json

      # Reset the selection_options names if it's a selection type
      if page.answer_settings.selection_options.present?
        # Clear the selection_options names, as we don't have any welsh translations yet
        answer_settings_cloned["selection_options"].each do |option|
          option["name"] = nil
        end

        # Save to the welsh answer_settings, where if will become a DataStruct
        page.answer_settings_cy = answer_settings_cloned
      end
    end

    if page_has_selection_options?
      self.selection_options_cy = page.answer_settings_cy&.selection_options
    end

    self
  end

  def page
    @page ||= Page.find(id)
    @page
  end

  def selection_options_cy=(incoming_hash)
    if incoming_hash.is_a?(Hash)
      values_array = incoming_hash.values
      super(values_array)
    else
      super(incoming_hash)
    end
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

  def page_has_selection_options?
    page.answer_type == "selection"
  end
end
