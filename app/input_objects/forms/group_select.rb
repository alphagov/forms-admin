class Forms::GroupSelect < BaseInput
  attr_accessor :form, :group

  validates :group, presence: true

  def groups
    groups = Group.for_organisation(group.organisation).excluding(group)

    if form.is_live?
      groups = groups.where(status: :active)
    end

    groups
  end
end
