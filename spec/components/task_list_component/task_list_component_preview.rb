class TaskListComponent::TaskListComponentPreview < ViewComponent::Preview
  def default
    render(TaskListComponent::View.new(sections: [
      { title: "Make a form",
        section_number: 1,
        subsection: false,
        rows: [
          { task_name: "Edit the name of your form", path: "#", status: :completed, active: true },
          { task_name: "Edit the questions of your form", path: "#", status: :not_started, active: true },
          { task_name: "Edit the declaration", path: "#", status: :cannot_start },
          { task_name: "Edit the information about what happens next", path: "#", status: :cannot_start, active: false },
        ] },
      { title: "Do something else with a form",
        section_number: 2,
        subsection: false,
        rows: [
          { task_name: "Edit the email address", path: "#", status: :cannot_start },
          { task_name: "Confirm the submission email address", path: "#", status: :cannot_start, active: false },
        ] },
      { title: "Read this",
        section_number: nil,
        subsection: true,
        body_text: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nunc sit amet ex nisl. Maecenas at erat mi. Nunc feugiat egestas ligula ac feugiat. Nam et dictum felis.\n\nCras cursus leo vitae vestibulum dictum. Donec sit amet turpis faucibus, bibendum leo vel, fermentum lacus." },
      { title: "Do yet another thing with a form",
        section_number: 3,
        subsection: false,
        rows: [
          { task_name: "Edit the privacy link", path: "#", status: :cannot_start },
          { task_name: "Edit the contact details", path: "#", status: :cannot_start, active: false },
        ] },
    ]))
  end

  def blank
    render(TaskListComponent::View.new)
  end

  def section_with_body_instead_of_rows
    render(TaskListComponent::View.new(sections: [{
      title: "Section with body instead of rows",
      body_text: "There are no tasks for you to do yet.\n\nMaybe there will be some later.",
      section_number: 1,
      subsection: false,
    }]))
  end

  def section_without_body_or_rows
    render(TaskListComponent::View.new(sections: [
      { title: "Make a form",
        rows: [],
        section_number: 1,
        subsection: false },
    ]))
  end

  def subsection
    render(TaskListComponent::View.new(sections: [
      { title: "Make a form",
        rows: [
          { task_name: "Edit the name of your form", path: "#", active: true },
        ],
        section_number: nil,
        subsection: true },
    ]))
  end

  def without_status
    render(TaskListComponent::View.new(sections: [
      { title: "Make a form",
        section_number: 1,
        subsection: false,
        rows: [
          { task_name: "Edit the name of your form", path: "#", active: true },
          { task_name: "Edit the email address", path: "#" },
        ] },
    ]))
  end

  def with_hint
    render(TaskListComponent::View.new(sections: [
      { title: "Make a form",
        section_number: 1,
        subsection: false,
        rows: [
          { task_name: "Edit the name of your form", path: "#", status: :not_started, active: true },
          { task_name: "Edit the questions of your form", path: "#", status: :cannot_start, active: false, hint_text: "You can only complete this step if you have entered a name for your form" },
          { task_name: "Edit the email address", path: "#", status: :not_started },
          { task_name: "Confirm the submission email address", path: "#", status: :not_started },
        ] },
    ]))
  end

  def with_confirm_set
    render(TaskListComponent::View.new(sections: [
      { title: "Make a form",
        section_number: 1,
        subsection: false,
        rows: [
          { task_name: "Edit the name of your form", path: "#", active: true, status: :completed, hint_text: "Describe your form clearly", confirm_path: "#confirm-path" },
          { task_name: "Edit the questions of your form", path: "#", status: :not_started, active: true },
          { task_name: "Edit the email address", path: "#", status: :cannot_start },
          { task_name: "Confirm the submission email address", path: "#", status: :cannot_start, active: false },
        ] },
    ]))
  end

  def with_status_summary
    render(TaskListComponent::View.new(
             completed_task_count: "1",
             total_task_count: "4",
             sections: [
               { title: "Make a form",
                 section_number: 1,
                 subsection: false,
                 rows: [
                   { task_name: "Edit the name of your form", path: "#", active: true, status: :completed, hint_text: "Describe your form clearly", confirm_path: "#confirm-path" },
                   { task_name: "Edit the questions of your form", path: "#", status: :not_started, active: true },
                   { task_name: "Edit the email address", path: "#", status: :cannot_start },
                   { task_name: "Confirm the submission email address", path: "#", status: :cannot_start, active: false },
                 ] },
             ],
           ))
  end

  def with_status_summary_all_tasks_completed
    render(TaskListComponent::View.new(
             completed_task_count: "4",
             total_task_count: "4",
             sections: [
               { title: "Make a form",
                 section_number: 1,
                 subsection: false,
                 rows: [
                   { task_name: "Edit the name of your form", path: "#", active: true, status: :completed, hint_text: "Describe your form clearly", confirm_path: "#confirm-path" },
                   { task_name: "Edit the questions of your form", path: "#", status: :completed, active: true },
                   { task_name: "Edit the email address", path: "#", status: :completed },
                   { task_name: "Confirm the submission email address", path: "#", status: :completed, active: false },
                 ] },
             ],
           ))
  end
end
