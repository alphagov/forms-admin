class TaskListComponent::TaskListComponentPreview < ViewComponent::Preview
  def default
    render(TaskListComponent::View.new(sections: [
      { title: "Make a form",
        rows: [
          { task_name: "Edit the name of your form", path: "#", status: :completed, active: true },
          { task_name: "Edit the questions of your form", path: "#", status: :not_started, active: true },
          { task_name: "Edit the email address", path: "#", status: :connot_start },
          { task_name: "Confirm the submission email address", path: "#", status: :connot_start, active: false },
        ] },
      { title: "do something else with a form",
        rows: [
          { task_name: "Edit the name of your form", path: "#", status: :completed, active: true },
          { task_name: "Edit the questions of your form", path: "#", status: :not_started, active: true },
          { task_name: "Edit the email address", path: "#", status: :connot_start },
          { task_name: "Confirm the submission email address", path: "#", status: :connot_start, active: false },
        ] },
    ]))
  end

  def blank
    render(TaskListComponent::View.new)
  end

  def section_without_rows
    render(TaskListComponent::View.new(sections: [
      { title: "Make a form", rows: [] },
    ]))
  end

  def without_status
    render(TaskListComponent::View.new(sections: [
      { title: "Make a form",
        rows: [
          { task_name: "Edit the name of your form", path: "#", active: true },
          { task_name: "Edit the email address", path: "#" },
        ] },
    ]))
  end

  def with_hint
    render(TaskListComponent::View.new(sections: [
      { title: "Make a form",
        rows: [
          { task_name: "Edit the name of your form", path: "#", status: :not_started, active: true },
          { task_name: "Edit the questions of your form", path: "#", status: :connot_start, active: false, hint_text: "You can only complete this step if you have entered a name for your form" },
          { task_name: "Edit the email address", path: "#", status: :not_started },
          { task_name: "Confirm the submission email address", path: "#", status: :not_started },
        ] },
    ]))
  end

  def with_confirm_set
    render(TaskListComponent::View.new(sections: [
      { title: "Make a form",
        rows: [
          { task_name: "Edit the name of your form", path: "#", active: true, status: :completed, hint_text: "Describe your form clearly", confirm_path: "#confirm-path" },
          { task_name: "Edit the questions of your form", path: "#", status: :not_started, active: true },
          { task_name: "Edit the email address", path: "#", status: :connot_start },
          { task_name: "Confirm the submission email address", path: "#", status: :connot_start, active: false },
        ] },
    ]))
  end
end
