class FormDocument::Content
  include ActiveModel::API
  include ActiveModel::Attributes

  attr_reader :steps

  attribute :form_id, :integer
  attribute :live_at, :datetime
  attribute :first_made_live_at, :datetime
  attribute :name, :string
  attribute :available_languages, array: true
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
  attribute :submission_format, array: true
  attribute :declaration_text, :string
  attribute :s3_bucket_region, :string
  attribute :submission_email, :string
  attribute :support_url_text, :string
  attribute :privacy_policy_url, :string
  attribute :s3_bucket_aws_account_id, :string
  attribute :what_happens_next_markdown, :string

  alias_attribute :id, :form_id

  def initialize(attributes = {})
    @steps = attributes.fetch("steps", []).map { |step| FormDocument::Step.new(**step) }
    attributes.slice!(*self.class.attribute_names)
    super
  end

  def made_live_date
    first_made_live_at&.to_date
  end

  def self.from_form_document(form_document)
    content = new(**form_document.content)

    # TODO: this can be removed once we've back-filled the first_made_live_at for existing forms.
    if content.live_at.present?
      # give the earliest date we have in the system that could be the date the form first went live, this won't be
      # accurate in the case where a form was archived and made live again
      content.first_made_live_at = [content.first_made_live_at, content.live_at, form_document.created_at].compact.min
    end

    content
  end
end
