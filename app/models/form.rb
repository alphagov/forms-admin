class Form < ApplicationRecord
  has_many :pages, -> { order(position: :asc) }, dependent: :destroy

  enum :submission_type, {
    email: "email",
    email_with_csv: "email_with_csv",
    s3: "s3",
  }

  after_create :set_external_id

private

  def set_external_id
    update(external_id: id)
  end
end
