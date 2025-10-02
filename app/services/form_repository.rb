class FormRepository
  class << self
    def save!(record)
      record.save!
      record.create_draft_from_live_form! if record.live?
      record.create_draft_from_archived_form! if record.archived?
      record
    end

    def pages(record)
      Form.find(record.id).pages
    end
  end
end
