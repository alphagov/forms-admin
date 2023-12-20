class Domain < ActiveYaml::Base
  include ActiveHash::Associations

  set_root_path Settings.config_data.path

  belongs_to :organisation, foreign_key: :govuk_content_id, primary_key: :govuk_content_id
end
