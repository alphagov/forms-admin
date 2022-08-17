class TaskListComponent::TaskListComponentPreview < ViewComponent::Preview

  def default
    render (TaskListComponent.new) do |tasklist|
      tasklist.with_section(title: 'Make a form') do |section|
        section.with_row(task_name: "Edit the name of your form", path: '#', status: :complete, active: true)
        section.with_row(task_name: "Edit the email address", path:  '#', status: :complete)
      end
    end
  end
end
