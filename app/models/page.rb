class Page < ActiveResource::Base
  self.site = (ENV["API_BASE"]).to_s
  self.prefix = "/api/v1/forms/:form_id/"
  self.include_format_in_path = false

  belongs_to :form
  validates :question_text, presence: true
  validates :answer_type, presence: true, inclusion: { in: %w[single_line address date email national_insurance_number phone_number] }

  def has_next?
    attributes.include?("next") && !attributes["next"].nil?
  end
end
