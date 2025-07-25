class Page < ApplicationRecord
  before_destroy :destroy_secondary_skip_conditions

  belongs_to :form
  has_many :routing_conditions, class_name: "Condition", foreign_key: "routing_page_id", dependent: :destroy
  has_many :check_conditions, class_name: "Condition", foreign_key: "check_page_id", dependent: :destroy
  has_many :goto_conditions, class_name: "Condition", foreign_key: "goto_page_id", dependent: :destroy
  acts_as_list scope: :form

  ANSWER_TYPES = %w[name organisation_name email phone_number national_insurance_number address date selection number text file].freeze

  ANSWER_TYPES_WITHOUT_SETTINGS = %w[organisation_name email phone_number national_insurance_number number].freeze

  ANSWER_TYPES_WITH_SETTINGS = %w[selection text date address name].freeze

  validates :question_text, presence: true
  validates :question_text, length: { maximum: 250 }

  validates :hint_text, length: { maximum: 500 }

  validates :answer_type, presence: true, inclusion: { in: ANSWER_TYPES }
  validate :guidance_fields_presence
  validates :page_heading, length: { maximum: 250 }
  validate :guidance_markdown_length_and_tags

  attribute :answer_settings, DataStructType.new

  def destroy_and_update_form!
    form = self.form
    destroy! && form.update!(question_section_completed: false)
  end

  def save_and_update_form
    return true unless has_changes_to_save?

    save!
    # TODO: https://trello.com/c/dg9CFPgp/1503-user-triggers-state-change-from-live-to-livewithdraft
    # Will not be needed when users can trigger this event themselves through the UI
    form.create_draft_from_live_form! if form.live?
    form.create_draft_from_archived_form! if form.archived?

    form.update!(question_section_completed: false)
    check_conditions.destroy_all if answer_type_changed_from_selection
    check_conditions.destroy_all if answer_settings_changed_from_only_one_option

    true
  end

  def answer_type_changed_from_selection
    answer_type_previously_was&.to_sym == :selection && answer_type&.to_sym != :selection
  end

  def answer_settings_changed_from_only_one_option
    from_only_one_option = ActiveModel::Type::Boolean.new.cast(answer_settings_previously_was.try(:[], "only_one_option"))
    to_multiple_options = !ActiveModel::Type::Boolean.new.cast(answer_settings.try(:[], "only_one_option"))

    from_only_one_option && to_multiple_options
  end

  def has_routing_errors
    routing_conditions.filter(&:has_routing_errors).any?
  end

  def question_with_number
    "#{position}. #{question_text}"
  end

  def show_optional_suffix?
    is_optional? && answer_type != "selection"
  end

private

  def guidance_fields_presence
    if page_heading.present? && guidance_markdown.blank?
      errors.add(:guidance_markdown, "must be present when Page Heading is present")
    elsif guidance_markdown.present? && page_heading.blank?
      errors.add(:page_heading, "must be present when Guidance Markdown is present")
    end
  end

  def guidance_markdown_length_and_tags
    return true if guidance_markdown.blank?

    markdown_validation = GovukFormsMarkdown.validate(guidance_markdown)

    return true if markdown_validation[:errors].empty?

    if markdown_validation[:errors].include?(:too_long)
      errors.add(:guidance_markdown, :too_long, count: 4999)
    end

    tag_errors = markdown_validation[:errors].excluding(:too_long)
    if tag_errors.any?
      errors.add(:guidance_markdown, :unsupported_markdown_syntax, message: "can only contain formatting for links, subheadings(##), bulleted listed (*), or numbered lists(1.)")
    end
  end

  def destroy_secondary_skip_conditions
    return if goto_conditions.empty?

    # We want to delete the secondary skip for the page at the start of the route
    # That association isn't in the database, so we need to dig it out
    # TODO: what if the page owning the routes has more than two routes?
    goto_conditions
      .filter { |condition| condition.check_page_id == condition.routing_page_id }
      .map(&:check_page)
      .flat_map(&:check_conditions)
      .filter { |condition| condition.check_page_id != condition.routing_page_id }
      .each(&:destroy!)
  end
end
