class FormRepository
  class << self
    def create!(creator_id:, name:)
      Api::V1::FormResource.create!(creator_id:, name:)
    end

    def find(form_id:)
      Api::V1::FormResource.find(form_id)
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
      form
    end

    def make_live!(record)
      form = Api::V1::FormResource.new(record.attributes, true)
      form.make_live!
      form
    end

    def archive!(record)
      form = Api::V1::FormResource.new(record.attributes, true)
      form.archive!
      form
    end

    def destroy(record)
      form = Api::V1::FormResource.new(record.attributes, true)
      form.destroy # rubocop:disable Rails/SaveBang
    end

    def pages(record)
      form = Api::V1::FormResource.new(record.attributes, true)
      form.pages
    end
  end
end
