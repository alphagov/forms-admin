require "rails_helper"

RSpec.describe TaskListComponent, type: :component do

  before do
    render_inline(TaskListComponent.new) do |tasklist|
      tasklist.with_section(title: 'Make a form') do |section|
        section.with_row(task_name: "Edit the name of your form", path: '#', status: :complete, active: true)
        section.with_row(task_name: "Edit the email address", path: '#', status: :complete)
      end
    end
  end

  it "renders something" do
    expect(rendered_component).to have_text('Make a form')
  end
end
