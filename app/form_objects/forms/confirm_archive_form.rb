class Forms::ConfirmArchiveForm < BaseForm
  attr_accessor :form, :confirm_archive

  CONFIRM_ARCHIVE_VALUES = { archive: "archive", do_not_archive: "do_not_archive" }.freeze

  validates :confirm_archive, presence: true, inclusion: { in: CONFIRM_ARCHIVE_VALUES.values }

  def archive?
    confirm_archive == CONFIRM_ARCHIVE_VALUES[:archive]
  end

  def values
    CONFIRM_ARCHIVE_VALUES.keys
  end
end
