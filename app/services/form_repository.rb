class FormRepository
  class << self
    def create!(creator_id:, name:)
      form = Api::V1::FormResource.create!(creator_id:, name:)
      Form.create!(form.database_attributes)
      form
    end

    def find(form_id:)
      form = Api::V1::FormResource.find(form_id)
      save_to_database!(form)
      form
    end

    def find_live(form_id:)
      Api::V1::FormResource.find_live(form_id)
    end

    def find_archived(form_id:)
      Api::V1::FormResource.find_archived(form_id)
    end

    def where(creator_id:)
      Api::V1::FormResource.where(creator_id:)
    end

    def save!(record)
      form = Api::V1::FormResource.new(record.attributes, true)
      form.save!
      save_to_database!(form)
      form
    end

    def make_live!(record)
      form = Api::V1::FormResource.new(record.attributes, true)

      response = form.make_live!
      form.from_json(response.body)

      save_to_database!(form)

      form
    end

    def archive!(record)
      form = Api::V1::FormResource.new(record.attributes, true)

      response = form.archive!
      form.from_json(response.body)

      save_to_database!(form)
      form
    end

    def destroy(record)
      form = Api::V1::FormResource.new(record.attributes, true)

      begin
        form.destroy # rubocop:disable Rails/SaveBang
        Form.destroy(record.id)
      rescue ActiveResource::ResourceNotFound, ActiveRecord::RecordNotFound
        # ActiveRecord::Persistence#destroy doesn't raise an error
        # if record has already been destroyed, let's emulate that
      end

      record
    end

    def pages(record)
      if Rails.env.test? && record.attributes.key?("pages")
        raise "Form response should not include pages, check the spec factories and mocks, or stub .pages instead"
      end

      form = Api::V1::FormResource.new(record.attributes, true)
      form.pages
    end

  private

    def save_to_database!(record)
      Form.upsert(record.database_attributes)
    end
  end
end
