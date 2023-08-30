class Forms::MakeLiveForm < BaseForm
  attr_accessor :form, :confirm_make_live

  CONFIRM_LIVE_VALUES = { made_live: "made_live", not_made_live: "not_made_live" }.freeze

  validates :confirm_make_live, presence: true, inclusion: { in: CONFIRM_LIVE_VALUES.values }

  validate :required_parts_of_form_completed

  def submit
    return false if invalid?
    # we are valid and didn't need to save
    return true unless made_live?

    form.make_live!
  end

  def made_live?
    confirm_make_live == CONFIRM_LIVE_VALUES[:made_live]
  end

  def values
    CONFIRM_LIVE_VALUES.keys
  end

private

  def required_parts_of_form_completed
    # we are valid and didn't need to save
    return unless made_live?
    return if form.ready_for_live?

    missing_sections = form.missing_sections

    if missing_sections.include?(:missing_pages)
      errors.add(:confirm_make_live, :missing_pages)
      return false
    end

    if missing_sections.include?(:missing_submission_email)
      errors.add(:confirm_make_live, :missing_submission_email)
      return false
    end

    if missing_sections.include?(:missing_privacy_policy_url)
      errors.add(:confirm_make_live, :missing_privacy_policy_url)
    end

    if missing_sections.include?(:missing_contact_details)
      errors.add(:confirm_make_live, :missing_contact_details)
      return false
    end

    if missing_sections.include?(:missing_what_happens_next)
      errors.add(:confirm_make_live, :missing_what_happens_next)
      false
    end
  end
end
