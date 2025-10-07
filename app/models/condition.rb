class Condition < ApplicationRecord
  include ConditionMethods
  belongs_to :routing_page, class_name: "Page"
  belongs_to :check_page, class_name: "Page", optional: true
  belongs_to :goto_page, class_name: "Page", optional: true

  has_one :form, through: :routing_page

  before_destroy :destroy_postconditions

  def self.create_and_update_form!(...)
    condition = Condition.new(...)
    condition.save_and_update_form
    condition
  end

  def save_and_update_form
    save!
    form.question_section_completed = false
    form.save_draft!
  end

  def destroy_and_update_form!
    destroy! && form.update!(question_section_completed: false)
  end

  def validation_errors
    [
      warning_goto_page_doesnt_exist,
      warning_answer_doesnt_exist,
      warning_routing_to_next_page,
      warning_goto_page_before_routing_page,
    ].compact
  end

  def warning_goto_page_doesnt_exist
    return nil if is_exit_page?
    # goto_page_id isn't needed if the route is skipping to the end of the form
    return nil if is_check_your_answers?

    page = form.pages.find_by(id: goto_page_id)
    return nil if page.present?

    DataStruct.new(name: "goto_page_doesnt_exist")
  end

  def warning_answer_doesnt_exist
    return nil if has_precondition? && answer_value.nil?

    answer_options = check_page&.answer_settings&.dig("selection_options")&.pluck("name")
    return nil if answer_options.blank? || answer_options.include?(answer_value) || answer_value == :none_of_the_above.to_s && check_page.is_optional?

    DataStruct.new(name: "answer_value_doesnt_exist")
  end

  def warning_routing_to_next_page
    return nil if check_page.nil? || goto_page.nil? && !is_check_your_answers?

    routing_page_position = routing_page.position
    goto_page_position = is_check_your_answers? ? form.pages.last.position + 1 : goto_page.position

    return DataStruct.new(name: "cannot_route_to_next_page") if goto_page_position == (routing_page_position + 1)

    nil
  end

  def warning_goto_page_before_routing_page
    if goto_page.present? && (goto_page.position <= routing_page.position)
      DataStruct.new(name: "cannot_have_goto_page_before_routing_page")
    end
  end

  def is_check_your_answers?
    goto_page.nil? && skip_to_end
  end

  def has_routing_errors
    validation_errors.any?
  end

  alias_method :has_routing_errors?, :has_routing_errors

  def errors_with_fields
    error_fields = {
      answer_value_doesnt_exist: :answer_value,
      goto_page_doesnt_exist: :goto_page_id,
      cannot_have_goto_page_before_routing_page: :goto_page_id,
      cannot_route_to_next_page: :goto_page_id,
    }
    validation_errors.map do |error|
      { name: error[:name], field: error_fields[error[:name].to_sym] || :answer_value }
    end
  end

  def as_json(options = {})
    super(options.reverse_merge(
      methods: %i[validation_errors has_routing_errors],
    ))
  end

  def as_form_document_condition
    as_json(methods: %i[validation_errors])
  end

private

  def has_precondition?
    check_page_id && check_page_id != routing_page_id && !check_page.routing_conditions.empty?
  end

  def destroy_postconditions
    return if check_page.nil?

    postconditions = check_page.check_conditions.filter { it != self && it.routing_page_id != it.check_page_id }
    postconditions.each(&:destroy!)
  end
end
