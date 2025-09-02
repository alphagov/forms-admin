class FormRepository
  class << self
    def create!(creator_id:, name:)
      form = Form.create!(creator_id:, name:)
      Api::V1::FormResource.create!(form.attributes)
      form
    end

    def find(form_id:)
      Form.find(form_id)
    end

    def where(creator_id:)
      Form.where(creator_id:)
    end

    def save!(record)
      record.save!
      record.create_draft_from_live_form! if record.live?
      record.create_draft_from_archived_form! if record.archived?
      Api::V1::FormResource.new(record.attributes, true).save!
      record
    end

    def make_live!(record)
      record.make_live!
      Api::V1::FormResource.new(record.attributes, true).make_live!
      record
    end

    def archive!(record)
      record.archive_live_form!
      Api::V1::FormResource.new(record.attributes, true).archive!
      record
    end

    def destroy(record)
      form = Api::V1::FormResource.new(record.attributes, true)

      begin
        form.destroy # rubocop:disable Rails/SaveBang
      rescue ActiveResource::ResourceNotFound
        # ActiveRecord::Persistence#destroy doesn't raise an error
        # if record has already been destroyed, let's emulate that
      end

      begin
        Form.destroy(record.id)
      rescue ActiveRecord::RecordNotFound
        # as above
      end

      record
    end

    def pages(record)
      Form.find(record.id).pages
    end
  end
end
