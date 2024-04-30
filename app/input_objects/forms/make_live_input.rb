class Forms::MakeLiveInput < ConfirmActionInput
  attr_accessor :form

  validate :required_parts_of_form_completed

private

  def required_parts_of_form_completed
    # we are valid and didn't need to save
    return unless confirmed?
    return if form.all_ready_for_live?

    form.all_incomplete_tasks.each do |section|
      errors.add(:confirm, section.to_sym)
    end

    errors.empty?
  end
end
