class FormRepository
  class << self
    def new(...)
      Api::V1::FormResource.new(...)
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

    def where(...)
      Api::V1::FormResource.where(...)
    end
  end
end
