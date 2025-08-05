class Forms::GroupSelect < BaseInput
  attr_accessor :form, :group

  def groups
    # TODO: change this to Groups in the Logged In User's Organisation only
    Group.all
  end

  def to_partial_path
    "input_objects/forms/group_select"
  end
end
