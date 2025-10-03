class Forms::SharePreviewInput < Forms::MarkCompleteInput
  def submit
    return false if invalid?

    form.share_preview_completed = mark_complete
    form.save_draft!
  end

  def assign_form_values
    self.mark_complete = form.try(:share_preview_completed)
    self
  end
end
