class FormDocument::Content
  include ActiveModel::API
  include ActiveModel::Attributes

  attr_reader :steps

  attribute :form_id, :integer
  attribute :live_at, :datetime
  attribute :name, :string
  attribute :language, :string
  attribute :form_slug, :string
  attribute :created_at, :datetime
  attribute :creator_id, :datetime
  attribute :start_page, :integer
  attribute :updated_at, :datetime
  attribute :payment_url, :string
  attribute :support_url, :string
  attribute :support_email, :string
  attribute :support_phone, :string
  attribute :s3_bucket_name, :string
  attribute :submission_type, :string
  attribute :declaration_text, :string
  attribute :s3_bucket_region, :string
  attribute :submission_email, :string
  attribute :support_url_text, :string
  attribute :privacy_policy_url, :string
  attribute :s3_bucket_aws_account_id, :string
  attribute :what_happens_next_markdown, :string

  alias_attribute :id, :form_id

  def initialize(attribute = {})
    @steps = attribute.fetch("steps", []).map { |step| FormDocument::Step.new(**step) }
    attribute.slice!(*self.class.attribute_names)
    super
  end

  def made_live_date
    live_at.to_date if live_at.present?
  end
end
