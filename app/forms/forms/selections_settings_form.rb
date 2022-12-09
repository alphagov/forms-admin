class Forms::SelectionsSettingsForm
  include ActiveModel::Model
  include ActiveModel::Validations
  include ActiveModel::Validations::Callbacks

  before_validation :filter_out_blank_options

  attr_accessor :selection_options, :only_one_option, :include_none_of_the_above

  validate :selection_options, :validate_selection_options
  # TODO: try to make this initialiser neater
  def initialize(params = {})
    @selection_options = params[:selection_options] ? params[:selection_options].values.map { |s| Forms::SelectionOption.new(s) } : []
    @only_one_option = params[:only_one_option]
    @include_none_of_the_above = params[:include_none_of_the_above]
  end

  def add_another
    selection_options.append(Forms::SelectionOption.new({ name: "" }))
  end

  def remove(index)
    selection_options.delete_at(index)
  end

  def answer_settings
    { only_one_option:, selection_options: }
  end

  def submit(session)
    return false if invalid?

    session[:page] = {} if session[:page].blank?

    session[:page][:answer_settings] = answer_settings
    session[:page][:is_optional] = include_none_of_the_above
  end

  def assign_values_to_page(page)
    return false if invalid?

    page.answer_settings = answer_settings
    page.is_optional = include_none_of_the_above
  end

  def validate_selection_options
    return errors.add(:selection_options, :minimum) if selection_options.length < 2
    return errors.add(:selection_options, :maximum) if selection_options.length > 20
    return errors.add(:selection_options, :uniqueness) if selection_options.map(&:name).uniq.length != selection_options.length
  end

  def filter_out_blank_options
    self.selection_options = selection_options.filter { |option| option.name.present? }
  end
end
