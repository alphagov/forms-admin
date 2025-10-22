class Pages::ChangeOrderService
  class FormPagesAddedError < StandardError; end

  def self.generate_new_page_order(page_ids_and_positions)
    pages_with_position = page_ids_and_positions.select { |page| page[:new_position].present? }
                                             .sort_by { |page| page[:new_position].to_i }
    pages_without_position = page_ids_and_positions.select { |page| page[:new_position].blank? }

    new_page_order = []
    (1..page_ids_and_positions.length).each do |position|
      # Select the first unplaced page with a new_position <= current position
      next_page_index = pages_with_position.index { |page| page[:new_position].to_i <= position }
      next_page = pages_with_position.delete_at(next_page_index) if next_page_index

      # If none, select the first unplaced page without a new_position using the current ordering
      if next_page.nil?
        next_page = pages_without_position.shift
      end

      # If still none, select the next unplaced page with a higher new_position
      if next_page.nil?
        next_page = pages_with_position.shift
      end

      new_page_order << next_page[:page_id]
    end

    new_page_order
  end

  def self.update_page_order(form:, page_ids_and_positions:)
    new_page_order = generate_new_page_order(page_ids_and_positions)

    raise FormPagesAddedError if (form.pages.pluck(:id) - new_page_order).any?

    Page.acts_as_list_no_update do
      new_page_order.map { |page_id| form.pages.find_by(id: page_id) }
                    .compact
                    .each_with_index { |page, index| page.update!(position: index + 1) }
    end

    form.save_question_changes!
  end
end
