class Organisation < ActiveYaml::Base
  include ActiveHash::Associations

  set_root_path Settings.config_data.path

  field :has_access, default: true

  has_many :forms
  has_many :users

  has_many :mou_signatures

  has_many :domains, primary_key: :govuk_content_id, foreign_key: :govuk_content_id
end
