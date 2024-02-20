class Group < ApplicationRecord
  belongs_to :organisation

  validates :name, presence: true
  before_create :set_external_id

  def to_param
    external_id
  end

private

  def set_external_id
    self.external_id = ExternalIdProvider.generate_id
  end
end
