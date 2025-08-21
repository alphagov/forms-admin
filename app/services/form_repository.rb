class FormRepository
  class << self
    def create!(creator_id:, name:)
      if Settings.use_database_as_truth
        form = Form.create!(creator_id:, name:)
        Api::V1::FormResource.create!(form.attributes)
        form
      else
        form = Api::V1::FormResource.create!(creator_id:, name:)
        save_to_database!(form)
      end
    end

    def find(form_id:)
      if Settings.use_database_as_truth
        Form.find(form_id)
      else
        form = Api::V1::FormResource.find(form_id)
        save_to_database!(form)
      end
    end

    def find_live(form_id:)
      Api::V1::FormResource.find_live(form_id)
    end

    def find_archived(form_id:)
      Api::V1::FormResource.find_archived(form_id)
    end

    def where(creator_id:)
      if Settings.use_database_as_truth
        Form.where(creator_id:)
      else
        Api::V1::FormResource.where(creator_id:)
      end
    end

    def save!(record)
      if Settings.use_database_as_truth
        record.save!
        record.create_draft_from_live_form! if record.live?
        record.create_draft_from_archived_form! if record.archived?
        Api::V1::FormResource.new(record.attributes, true).save!
        record
      else
        form = Api::V1::FormResource.new(record.attributes, true)
        form.save!
        db_form = save_to_database!(form)
        db_form.create_draft_from_live_form! if db_form.live?
        db_form.create_draft_from_archived_form! if db_form.archived?
        db_form
      end
    end

    def make_live!(record)
      if Settings.use_database_as_truth
        record.make_live!
        Api::V1::FormResource.new(record.attributes, true).make_live!
        record
      else
        form = Api::V1::FormResource.new(record.attributes, true)

        save_pages_to_database!(form, form.pages) if Form.find(record.id).pages.empty?

        form.make_live!

        db_form = Form.find(record.id)
        db_form.make_live!
        db_form
      end
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
      unless Settings.use_database_as_truth
        if Rails.env.test? && record.attributes.key?("pages")
          raise "Form response should not include pages, check the spec factories and mocks, or stub .pages instead"
        end

        form = Api::V1::FormResource.new(record.attributes, true)

        pages = form.pages
        save_pages_to_database!(record, pages)
      end

      Form.find(record.id).pages
    end

  private

    def save_to_database!(record)
      Form.upsert(record.database_attributes)
      Form.find(record.id)
    end

    def save_pages_to_database!(form_record, page_records)
      pages_attributes = page_records.map(&:database_attributes)

      Page.upsert_all(pages_attributes)

      # delete any pages that may have previously been associated with this form
      form = Form.find(form_record.id)
      form.update!(page_ids: pages_attributes.pluck("id"))

      page_records.map { |page| save_routing_conditions_to_database!(page) }
    end

    def save_routing_conditions_to_database!(page_record)
      return if page_record.attributes["routing_conditions"].blank?

      routing_conditions = page_record.routing_conditions.map(&:database_attributes)

      Condition.upsert_all(routing_conditions)

      # delete any routing conditions that may have previously been associated with this page
      page = Page.find(page_record.id)
      page.update!(routing_condition_ids: routing_conditions.pluck("id"))
    end
  end
end
