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
    return if form.all_ready_for_live?

    form.all_incomplete_tasks.each do |section|
      errors.add(:confirm_make_live, section)
    end

    errors.empty?
  end
end
