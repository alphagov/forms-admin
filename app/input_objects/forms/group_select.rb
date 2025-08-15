class Forms::GroupSelect < BaseInput
  attr_accessor :form, :group

  validates :group, presence: true

  def groups
    groups = Group.for_organisation(group.organisation).excluding(group)

    if form.is_live? || form.is_archived?
      groups = groups.where(status: :active)
    end

    groups
  end
end
