class Forms::MakeLiveForm < BaseForm
  attr_accessor :form, :confirm_make_live

  CONFIRM_LIVE_VALUES = { made_live: "made_live", not_made_live: "not_made_live" }.freeze

  validates :confirm_make_live, presence: true, inclusion: { in: CONFIRM_LIVE_VALUES.values }

  validate :required_parts_of_form_completed
  def made_live?
    confirm_make_live == CONFIRM_LIVE_VALUES[:made_live]
  end

  def values
    CONFIRM_LIVE_VALUES.keys
  end

  def user_wants_to_make_form_live
    valid? && made_live?
  end

  def make_form_live(service)
    valid? && service.make_live
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
