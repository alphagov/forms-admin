class Pages::UpdateExitPageInput < BaseInput
  attr_accessor :form, :page, :record, :exit_page_markdown, :exit_page_heading

  validates :exit_page_heading, :exit_page_markdown, presence: true

  def submit
    return false if invalid?

    record.exit_page_heading = exit_page_heading
    record.exit_page_markdown = exit_page_markdown
    record.goto_page_id = nil
    record.skip_to_end = false

    ConditionRepository.save!(record)
  end

  def assign_condition_values
    self.exit_page_heading = record.exit_page_heading
    self.exit_page_markdown = record.exit_page_markdown
    self
  end
end
