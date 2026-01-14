class Forms::WelshSelectionOptionTranslationInput < BaseInput
  include TextInputHelper
  include ActionView::Helpers::FormTagHelper
  include ActiveModel::Attributes

  attr_accessor :selection_option, :page

  attribute :id, :integer
  attribute :name_cy

  def initialize(attributes = {})
    @selection_option = attributes.delete(:selection_option) if attributes.key?(:selection_option)
    @page = attributes.delete(:page) if attributes.key?(:page)
    super
  end

  def assign_selection_option_values
    return self unless selection_option

    self.name_cy = selection_option.name
    self
  end

  def as_selection_option
    { name: name_cy, value: selection_option.value }
  end

  def form_field_id(attribute)
    field_id(:forms_welsh_selection_option_translation_input, page.id, :selection_options_cy, id, attribute)
  end

  def selection_number
    id + 1
  end

  def question_number
    page.position
  end
end
