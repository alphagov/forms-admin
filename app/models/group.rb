class Group < ApplicationRecord
  validates :name, presence: true
  before_create :set_external_id

  def to_param
    external_id
  end

private

  def set_external_id
    self.external_id = SecureRandom.urlsafe_base64(10)
  end
end
