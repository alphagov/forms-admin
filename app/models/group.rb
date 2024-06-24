class Group < ApplicationRecord
  belongs_to :organisation

  belongs_to :creator, class_name: "User", optional: true

  belongs_to :upgrade_requester, class_name: "User", optional: true

  has_many :memberships, dependent: :destroy do
    def ordered
      joins(:user).order("users.name")
    end
  end
  has_many :users, through: :memberships do
    def group_admins
      where(memberships: { role: "group_admin" })
    end
  end

  has_many :group_forms, dependent: :restrict_with_exception

  scope :for_user, ->(user) { joins(:memberships).where(memberships: { user_id: user.id }) }

  scope :for_organisation, ->(organisation) { where(organisation:) }

  validates :name, presence: true, uniqueness: { scope: :organisation_id }
  before_create :set_external_id

  enum :status, { trial: "trial", active: "active", upgrade_requested: "upgrade_requested" }, validate: true

  def to_param
    external_id
  end

private

  def set_external_id
    self.external_id = ExternalIdProvider.generate_id
  end
end
