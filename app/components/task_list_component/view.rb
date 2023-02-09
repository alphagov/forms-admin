module TaskListComponent
  class View < GovukComponent::Base
    attr_accessor :sections, :completed_task_count, :total_task_count

    Section = Struct.new(:rows, :title, :number, keyword_init: true)

    def initialize(completed_task_count: nil, total_task_count: nil, sections: [], classes: [], html_attributes: {})
      @count = 0
      super(classes:, html_attributes:)
      @sections = sections.blank? ? [] : sections.map { |s| build_section(s) }
      @completed_task_count = completed_task_count
      @total_task_count = total_task_count
    end

    def render_counter?
      return false unless @completed_task_count.present? && @total_task_count.present?
      return true if FeatureService.enabled?(:draft_live_versioning)

      @completed_task_count != @total_task_count
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
      number = counter
      Section.new(rows: build_rows(rows), title:, number:)
    end

    def build_rows(rows)
      rows.map { |r| Row.new(**r) }
    end
  end

  class Row
    attr_accessor :task_name, :status, :hint_text, :active

    def initialize(task_name:, path:, confirm_path: nil, status: nil, hint_text: nil, active: true)
      @task_name = task_name
      @path = path
      @confirm_path = confirm_path
      @status = status
      @hint_text = hint_text
      @active = active
    end

    def get_path
      # allow the caller to set confirm_path, an alternate
      # url for the link if the status is complete
      return path unless @confirm_path

      if status != :completed
        path
      else
        confirm_path
      end
    end

    def get_status_colour
      {
        completed: nil,
        in_progress: "blue",
        cannot_start: "grey",
        not_started: "grey",
      }[status.downcase.to_sym]
    end

    def status_id
      "#{task_name.downcase.parameterize}-status" if status
    end

  private

    def path
      @path.respond_to?(:call) ? @path.call : @path
    end

    def confirm_path
      @confirm_path.respond_to?(:call) ? @confirm_path.call : @confirm_path
    end
  end
end
