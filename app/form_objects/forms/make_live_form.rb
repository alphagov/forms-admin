class Forms::MakeLiveForm < ConfirmActionForm
  attr_accessor :form

  validate :required_parts_of_form_completed

  def user_wants_to_make_form_live
    valid? && confirmed?
  end

  def make_form_live(service)
    valid? && service.make_live
  end

private

  def required_parts_of_form_completed
    # we are valid and didn't need to save
    return unless confirmed?
    return if form.all_ready_for_live?

    form.all_incomplete_tasks.each do |section|
      errors.add(:confirm, section)
    end

    errors.empty?
  end
end
