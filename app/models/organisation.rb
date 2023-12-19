class Organisation < ApplicationRecord
  has_paper_trail

  has_many :forms
  has_many :users

  has_many :mou_signatures

  has_many :domains, primary_key: :govuk_content_id, foreign_key: :govuk_content_id
end
