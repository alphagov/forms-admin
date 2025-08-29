class FormDocument::Condition
  include ActiveModel::API
  include ActiveModel::Attributes

  include ConditionMethods

  attribute :id, :integer
  attribute :created_at, :datetime
  attribute :updated_at, :datetime
  attribute :skip_to_end, :boolean
  attribute :answer_value, :string
  attribute :goto_page_id, :integer
  attribute :check_page_id, :integer
  attribute :routing_page_id, :integer
  attribute :exit_page_heading, :string
  attribute :validation_errors, DataStructType.new
  attribute :exit_page_markdown, :string

  def initialize(attributes = {})
    attributes.slice!(*self.class.attribute_names)
    super
  end
end
