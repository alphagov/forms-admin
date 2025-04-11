class Pages::ExitPageInput < BaseInput
  attr_accessor :form, :page, :record, :exit_page_markdown, :exit_page_heading, :answer_value

  validates :exit_page_heading, :exit_page_markdown, :answer_value, presence: true

  def submit
    return false if invalid?

    ConditionRepository.create!(form_id: form.id,
                                page_id: page.id,
                                check_page_id: page.id,
                                routing_page_id: page.id,
                                answer_value:,
                                goto_page_id: nil,
                                skip_to_end: nil,
                                exit_page_heading:,
                                exit_page_markdown:)
  end
end
