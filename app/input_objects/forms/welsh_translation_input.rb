class Forms::WelshTranslationInput < Forms::MarkCompleteInput
  include TextInputHelper

  attr_accessor :page_translations

  def submit
    return false if invalid?

    page_translations.each(&:submit)

    form.welsh_completed = mark_complete
    form.save_draft!
  end

  def assign_form_values
    self.mark_complete = form.try(:welsh_completed)
    self
  end
end
