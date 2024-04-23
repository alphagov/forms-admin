module TaskListComponent
  class View < GovukComponent::Base
    attr_accessor :sections, :completed_task_count, :total_task_count

    Section = Struct.new(:rows, :title, :number, :subsection, :body_text, keyword_init: true)

    def initialize(completed_task_count: nil, total_task_count: nil, sections: [], classes: [], html_attributes: {})
      @count = 0
      super(classes:, html_attributes:)
      @sections = sections.blank? ? [] : sections.map { |s| build_section(s) }
      @completed_task_count = completed_task_count
      @total_task_count = total_task_count
    end

    def render_counter?
      @completed_task_count.present? && @total_task_count.present?
    end

  private

    def default_attributes
      { class: %w[app-task-list] }
    end

    def counter
      @count += 1
    end

    def build_section(section_fields)
      title = section_fields.fetch(:title)
      rows = section_fields.fetch(:rows) { [] }
      number = section_fields.fetch(:section_number)
      body_text = section_fields[:body_text]
      subsection = section_fields.fetch(:subsection)
      Section.new(rows: build_rows(rows), title:, number:, body_text:, subsection:)
    end

    def build_rows(rows)
      rows.map { |r| Row.new(**r) }
    end
  end

  class Row
    attr_accessor :task_name, :status, :hint_text, :active

    def initialize(task_name:, path:, status: nil, hint_text: nil, active: true)
      @task_name = task_name
      @path = path
      @status = status
      @hint_text = hint_text
      @active = active
    end

    def get_path
      return nil unless active

      @path
    end

    def get_status_colour
      return nil if status.blank?

      {
        completed: nil,
        in_progress: "blue",
        cannot_start: "grey",
        not_started: "grey",
        optional: "grey",
      }[status.downcase.to_sym]
    end

    def status_id
      "#{task_name.downcase.parameterize}-status" if status
    end

    def cannot_start?
      status == :cannot_start
    end

    def get_status_text
      I18n.t("task_statuses.#{status}")
    end

    def get_status_tag
      return nil if status.blank?

      GovukComponent::TagComponent.new(text: get_status_text, colour: get_status_colour).call
    end
  end
end
