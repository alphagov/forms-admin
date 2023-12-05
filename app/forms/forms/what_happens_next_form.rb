class Forms::WhatHappensNextForm < BaseForm
  attr_accessor :form, :what_happens_next_markdown

  validates :what_happens_next_markdown, markdown: { allow_headings: false }

  def submit
    return false if invalid?

    form.what_happens_next_markdown = what_happens_next_markdown
    form.save!
  end

  def assign_form_values
    self.what_happens_next_markdown = form.what_happens_next_markdown
    self
  end
end
