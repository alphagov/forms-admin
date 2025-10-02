class FormRepository
  class << self
    def save!(record)
      record.save!
      record.create_draft_from_live_form! if record.live?
      record.create_draft_from_archived_form! if record.archived?
      record
    end

    def make_live!(record)
      record.make_live!
      record
    end

    def archive!(record)
      record.archive_live_form!
      record
    end

    def destroy(record)
      begin
        Form.destroy(record.id)
      rescue ActiveRecord::RecordNotFound
        # ActiveRecord::Persistence#destroy doesn't raise an error
        # if record has already been destroyed, let's emulate that
      end

      record
    end

    def pages(record)
      Form.find(record.id).pages
    end
  end
end
