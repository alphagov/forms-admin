class Forms::GroupSelect < BaseInput
  attr_accessor :form, :group

  validates :group, presence: true

  def groups
    # TODO: change this to Groups in the Logged In User's Organisation only
    Group.where(organisation: group.organisation).excluding(group)
  end

  def to_partial_path
    "input_objects/forms/group_select"
  end
end
