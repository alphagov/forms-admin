class Forms::DeclarationInput < Forms::MarkCompleteInput
  include TextInputHelper

  attr_accessor :declaration_markdown

  validates :declaration_markdown, length: { maximum: 2000 }
  validates :declaration_markdown, markdown: { allow_headings: true }

  before_validation :strip_carriage_returns_from_input

  def submit
    return false if invalid?

    form.declaration_markdown = declaration_markdown
    form.declaration_section_completed = mark_complete
    form.save_draft!
  end

  def assign_form_values
    self.declaration_markdown = form.declaration_markdown
    self.mark_complete = form.try(:declaration_section_completed)
    self
  end

private

  def strip_carriage_returns_from_input
    strip_carriage_returns!(declaration_markdown)
  end
end
