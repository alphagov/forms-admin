class FormRepository
  class << self
    def create!(creator_id:, name:)
      Form.create!(creator_id:, name:)
    end

    def find(form_id:)
      Form.find(form_id)
    end

    def find_live(form_id:)
      Form.find_live(form_id)
    end

    def find_archived(form_id:)
      Form.find_archived(form_id)
    end

    def where(creator_id:)
      Form.where(creator_id:)
    end

    def save!(record)
      form = Form.new(record.attributes, true)
      form.save!
      form
    end

    def make_live!(record)
      form = Form.new(record.attributes, true)
      form.make_live!
      form
    end

    def archive!(record)
      form = Form.new(record.attributes, true)
      form.archive!
      form
    end

    def destroy(record)
      form = Form.new(record.attributes, true)
      form.destroy # rubocop:disable Rails/SaveBang
    end

    # todo
    # def pages(record)
    #   record.pages
    # end
  end
end
