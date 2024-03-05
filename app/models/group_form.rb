class GroupForm < ApplicationRecord
  self.primary_key = %i[form_id group_id]
  self.table_name = :groups_form_ids

  belongs_to :group

  def form
    Form.find(form_id)
  end
end
