class Forms::WelshTranslationInput < Forms::MarkCompleteInput
  include TextInputHelper
  include ActiveModel::Attributes

  attr_accessor :form, :page_translations

  attribute :mark_complete

  attribute :name_cy
  attribute :privacy_policy_url_cy
  attribute :support_email_cy
  attribute :support_phone_cy
  attribute :support_url_cy
  attribute :support_url_text_cy
  attribute :declaration_text_cy
  attribute :what_happens_next_markdown_cy
  attribute :payment_url_cy

  validates :name_cy, presence: true, if: -> { form_marked_complete? }
  validates :privacy_policy_url_cy, presence: true, if: -> { form_marked_complete? && form.privacy_policy_url.present? }

  validates :support_email_cy, presence: true, if: -> { form_marked_complete? && form_has_support_email? }
  validates :support_email_cy, email_address: true, allowed_email_domain: true, if: -> { support_email_cy.present? }

  validates :support_phone_cy, presence: true, if: -> { form_marked_complete? && form_has_support_phone? }
  validates :support_phone_cy, length: { maximum: 500 }, if: -> { support_phone_cy.present? }

  validates :support_url_cy, presence: true, if: -> { form_marked_complete? && form_has_support_url? }
  validates :support_url_cy, url: true, length: { maximum: 120 }, if: -> { support_url_cy.present? }

  validates :support_url_text_cy, presence: true, if: -> { form_marked_complete? && form_has_support_url? }
  validates :support_url_text_cy, length: { maximum: 120 }, if: -> { support_url_text_cy.present? }

  validates :declaration_text_cy, presence: true, if: -> { form_marked_complete? && form_has_declaration? }

  validates :what_happens_next_markdown_cy, presence: true, if: -> { form_marked_complete? && form.what_happens_next_markdown.present? }
  validates :what_happens_next_markdown_cy, markdown: { allow_headings: false }, if: -> { what_happens_next_markdown_cy.present? }

  validates :payment_url_cy, presence: true, if: -> { form_marked_complete? && form_has_payment_url? }

  validate :page_translations_valid

  def submit
    return false if invalid?

    form.name_cy = name_cy
    form.declaration_text_cy = form_has_declaration? ? declaration_text_cy : nil
    form.payment_url_cy = form_has_payment_url? ? payment_url_cy : nil
    form.privacy_policy_url_cy = privacy_policy_url_cy
    form.support_email_cy = form_has_support_email? ? support_email_cy : nil
    form.support_phone_cy = form_has_support_phone? ? support_phone_cy : nil

    if form_has_support_url?
      form.support_url_cy = support_url_cy
      form.support_url_text_cy = support_url_text_cy
    else
      form.support_url_cy = nil
      form.support_url_text_cy = nil
    end

    form.what_happens_next_markdown_cy = what_happens_next_markdown_cy

    if page_translations.present?
      page_translations.each(&:submit)
    end

    form.welsh_completed = mark_complete
    form.save_draft!
  end

  def assign_form_values
    self.name_cy = form.name_cy
    self.privacy_policy_url_cy = form.privacy_policy_url_cy
    self.support_email_cy = form.support_email_cy
    self.support_phone_cy = form.support_phone_cy
    self.support_url_cy = form.support_url_cy
    self.support_url_text_cy = form.support_url_text_cy
    self.declaration_text_cy = form.declaration_text_cy
    self.what_happens_next_markdown_cy = form.what_happens_next_markdown_cy
    self.payment_url_cy = form.payment_url_cy

    self.mark_complete = form.try(:welsh_completed)
    self
  end

  def form_has_declaration?
    form.declaration_text.present?
  end

  def form_has_payment_url?
    form.payment_url.present?
  end

  def form_has_support_url?
    form.support_url.present?
  end

  def form_has_support_phone?
    form.support_phone.present?
  end

  def form_has_support_email?
    form.support_email.present?
  end

  def form_has_support_information?
    form_has_support_email? || form_has_support_phone? || form_has_support_url?
  end

  def form_has_what_happens_next?
    form.what_happens_next_markdown.present?
  end

  def form_has_privacy_information?
    form.privacy_policy_url.present?
  end

  def form_marked_complete?
    mark_complete == "true"
  end

  def page_translations_valid
    return if page_translations.nil?

    page_translations.each do |page_translation|
      page_translation.validate

      page_translation.errors.each do |error|
        errors.import(error, { attribute: "page_#{page_translation.page.position}_#{error.attribute}".to_sym })
      end
    end
  end
end
