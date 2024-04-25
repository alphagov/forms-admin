class ConfirmActionForm < BaseForm
  attr_accessor :confirm

  RADIO_OPTIONS = { yes: "yes", no: "no" }.freeze

  validates :confirm, presence: true, inclusion: { in: RADIO_OPTIONS.values }

  def confirmed?
    confirm == RADIO_OPTIONS[:yes]
  end

  def values
    RADIO_OPTIONS.keys
  end
end
