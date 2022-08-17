class TaskListComponent < GovukComponent::Base
  renders_many :sections, -> (title:, classes: []) do
    SectionComponent.new(title:, number: counter, classes: classes)
  end

  def initialize(sections: nil, classes: [], html_attributes: {})
    super(classes: classes, html_attributes: html_attributes)
    @count = 0
  end

  private

  def default_attributes
    { class: %w[app-task-list] }
  end

  def counter
    @count = @count + 1
  end

end
