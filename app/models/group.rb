class Group < ApplicationRecord
  belongs_to :creator, class_name: "User", optional: true
  belongs_to :organisation

  belongs_to :default_for, polymorphic: true, optional: true

  has_many :memberships, dependent: :destroy
  has_many :users, through: :memberships

  has_many :group_forms, dependent: :restrict_with_exception

  scope :for_organisation, ->(organisation) { where(organisation:) }
  scope :for_user, ->(user) { joins(:memberships).where(memberships: { user_id: user.id }) }

  validates :name, presence: true
  before_create :set_external_id

  enum :status, { trial: "trial", active: "active" }, validate: true

  def to_param
    external_id
  end

private

  def set_external_id
    self.external_id = ExternalIdProvider.generate_id
  end
end
