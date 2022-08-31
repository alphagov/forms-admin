class Forms::MakeLiveForm
  include ActiveModel::Model
  include ActiveModel::Validations

  attr_accessor :form, :confirm_make_live

  CONFIRM_LIVE_VALUES = { made_live: "made_live", not_made_live: "not_made_live" }.freeze

  validates :confirm_make_live, presence: true, inclusion: { in: CONFIRM_LIVE_VALUES.values }

  def submit
    return false if invalid?
    # we are valid and didn't need to save
    return true unless made_live?

    form.live_at = Time.zone.now
    form.save!
  end

  def made_live?
    confirm_make_live == CONFIRM_LIVE_VALUES[:made_live]
  end

  def values
    CONFIRM_LIVE_VALUES.keys
  end
end
