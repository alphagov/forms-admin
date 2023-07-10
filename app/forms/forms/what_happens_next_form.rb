class Forms::WhatHappensNextForm < BaseForm
  attr_accessor :form, :what_happens_next_text

  validates :what_happens_next_text, length: { maximum: 2000 }

  def submit
    return false if invalid?

    form.what_happens_next_text = what_happens_next_text
    form.save!
  end

  def assign_form_values
    self.what_happens_next_text = form.what_happens_next_text
    self
  end
end
