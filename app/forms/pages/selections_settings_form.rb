class Pages::SelectionsSettingsForm < BaseForm
  include ActiveModel::Validations::Callbacks

  DEFAULT_OPTIONS = { selection_options: [OpenStruct.new(name: ""), OpenStruct.new(name: "")],
                      only_one_option: false,
                      include_none_of_the_above: false }.freeze

  attr_accessor :selection_options, :only_one_option, :include_none_of_the_above

  before_validation :filter_out_blank_options

  validate :selection_options, :validate_selection_options

  def add_another
    selection_options.append({ name: "" })
  end

  def remove(index)
    selection_options.delete_at(index)
  end

  def answer_settings
    { only_one_option:, selection_options: selection_options.map { |option| { name: option[:name] } } }
  end

  def submit(session)
    return false if invalid?

    session[:page] = {} if session[:page].blank?

    session[:page][:answer_settings] = answer_settings
    session[:page][:is_optional] = include_none_of_the_above
  end

  def validate_selection_options
    return errors.add(:selection_options, :minimum) if selection_options.length < 2
    return errors.add(:selection_options, :maximum) if selection_options.length > 20

    names = selection_options.map { |option| option[:name] }
    return errors.add(:selection_options, :uniqueness) if names.uniq.length != selection_options.length
  end

  def filter_out_blank_options
    self.selection_options = selection_options.filter { |option| option[:name].present? }
  end
end
