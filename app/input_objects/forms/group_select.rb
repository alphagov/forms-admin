class Forms::GroupSelect < BaseInput
  attr_accessor :form, :group

  validates :group, presence: true

  def groups
    form_record = Form.find(form.id)

    groups = Group.for_organisation(group.organisation).excluding(group)

    if form_record.has_live_version || form_record.has_been_archived
      groups = groups.where(status: :active)
    end

    groups
  end
end
