class CreateFormService
  class CreateFormEvent < ApplicationRecord
    belongs_to :user
    belongs_to :group
  end

  def create!(creator:, group:, name:)
    event = begin
      CreateFormEvent.create!(group:, form_name: name, user: creator, dedup_version: 1)
    rescue ActiveRecord::RecordNotUnique
      # If a form with the same name in the same group was created by the same
      # user less than a second ago, assume that this was a duplicate request
      # and return the form ID of the previously created form
      previous_event = CreateFormEvent.order(created_at: :desc).find_by(group:, form_name: name)

      if previous_event.user == creator && previous_event.created_at > 1.second.ago
        while previous_event.form_id.blank?
          sleep(0.01)
          previous_event.reload
        end

        previous_event
      else
        CreateFormEvent.create!(group:, form_name: name, user: creator, dedup_version: previous_event.dedup_version + 1)
      end
    end

    if event.form_id.present?
      form = FormRepository.find(form_id: event.form_id)
    else
      form = FormRepository.create!(creator_id: creator.id, name:)
      GroupForm.create!(group:, form_id: form.id)
      event.update!(form_id: form.id)
    end

    form
  end
end
