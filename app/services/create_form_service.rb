class CreateFormService
  def create!(creator:, group:, name:)
    form = FormRepository.create!(creator_id: creator.id, name:)
    GroupForm.create!(group:, form_id: form.id)

    form
  end
end
