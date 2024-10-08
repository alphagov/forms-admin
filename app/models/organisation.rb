class Organisation < ApplicationRecord
  has_paper_trail

  has_many :groups
  has_many :users

  has_many :mou_signatures

  scope :not_closed, -> { where(closed: false) }
  scope :with_users, -> { joins(:users).distinct.order(:name) }

  def name_with_abbreviation
    if abbreviation.present? && abbreviation != name
      "#{name} (#{abbreviation})"
    else
      name
    end
  end

  def admin_users
    users.organisation_admin
  end
end
