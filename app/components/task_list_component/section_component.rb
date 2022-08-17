class TaskListComponent::SectionComponent < GovukComponent::Base
  renders_many :rows, "Row"
  attr_accessor :title, :number

  def any_row_has_status?
    rows.any? { |r| r.status.present? }
  end

  def initialize(rows: nil, title:, number:, classes: [], html_attributes: {})
    @title = title
    @number = number
    super(classes: classes, html_attributes: html_attributes)
  end

private

  def default_attributes
    { class: %w[app-task-list] }
  end

class Row < GovukComponent::Base
  attr_accessor :task_name, :status, :hint_text, :active

  def initialize(task_name:, path:, confirm_path: nil, status:, hint_text: nil, active: true, classes: [], html_attributes: {})
    super(classes: classes, html_attributes: html_attributes)

    @task_name = task_name
    @path = path
    @confirm_path = confirm_path
    @status = status
    @hint_text = hint_text
    @active = active
  end

  def get_path
    return path unless @confirm_path

    # if Progress::STATUSES.slice(:incomplete, :in_progress_invalid).values.include?(status)
    #   path
    # else
    #   confirm_path
    # end
  end

  def get_status_colour
    {
      completed: "blue"
    }.fetch(status, "grey")
    # {
      # use default white text on dark blue background
      # Progress::STATUSES[:completed] => "blue",
      # Progress::STATUSES[:in_progress_valid] => "grey",
      # Progress::STATUSES[:in_progress_invalid] => "grey",
      # Progress::STATUSES[:review] => "pink",
      # Progress::STATUSES[:incomplete] => "grey",
    # }.fetch(status, "grey")
  end

  def status_id
    "#{task_name.downcase.parameterize}-status"
  end

private

  def path
    @path.respond_to?(:call) ? @path.call : @path
  end

  def confirm_path
    @confirm_path.respond_to?(:call) ? @confirm_path.call : @confirm_path
  end

  def default_attributes
    { class: %w[app-task-list__item] }
  end
end
end
